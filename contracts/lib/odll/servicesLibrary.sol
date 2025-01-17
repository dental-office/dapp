pragma solidity 0.4.18;

import "./utilities.sol";

library servicesLibrary {
  function addDentist(address dbAddress, uint serviceTypeId, uint[] serviceIds, address userId) internal {
    for (uint i = 0; i < serviceIds.length; i++) {
      addDentistToService(dbAddress, serviceTypeId, serviceIds[i], userId);
    }
  }

  function addDentistToService(address dbAddress, uint serviceTypeId, uint serviceId, address userId) internal {
    if (serviceTypeId == 1) {
      utilities.addRemovableIdItem(dbAddress, userId, "dentist/scan-service", "dentist/scan-services-count", "dentist/scan-service-key", serviceId);
      utilities.addRemovableIdItem(dbAddress, serviceId, "scan-service/dentist", "scan-service/dentists-count", "scan-service/dentist-key", userId);
    } else if (serviceTypeId == 2){
      utilities.addRemovableIdItem(dbAddress, userId, "dentist/treatment-service", "dentist/treatment-services-count", "dentist/treatment-service-key", serviceId);
      utilities.addRemovableIdItem(dbAddress, serviceId, "treatment-service/dentist", "treatment-service/dentists-count", "treatment-service/dentist-key", userId);
    }
  }

  function handleRemoveDentistService(address dbAddress, uint serviceTypeId, uint serviceId, address userId) internal {
    if (serviceTypeId == 1) {
      utilities.removeIdItem(dbAddress, userId, "dentist/scan-service", serviceId);
      utilities.removeIdItem(dbAddress, serviceId, "scan-service/dentist", userId);
    } else if (serviceTypeId == 2){
      utilities.removeIdItem(dbAddress, userId, "dentist/treatment-service", serviceId);
      utilities.removeIdItem(dbAddress, serviceId, "treatment-service/dentist", userId);
    }
  }

  function removeDentist(address dbAddress, uint serviceTypeId, uint[] serviceIds, address userId) internal {
    for (uint i = 0; i < serviceIds.length; i++) {
      handleRemoveDentistService(dbAddress, serviceTypeId, serviceIds[i], userId);
    }
  }

  function setFees(address dbAddress, uint serviceTypeId, uint[] serviceIds, uint[] fees, address userId) internal {
    if (serviceIds.length == 0 || fees.length == 0 || serviceIds.length != fees.length) {
      return;
    }

    for (uint i = 0; i < serviceIds.length; i++) {
      setFee(dbAddress, serviceTypeId, serviceIds[i], fees[i], userId);
    }
  }

  function setFee(address dbAddress, uint serviceTypeId, uint serviceId, uint fee, address userId) internal {
    if (serviceTypeId == 1) {
      DB(dbAddress).setUIntValue(keccak256("dentist/scan-service/fee", userId, serviceId), fee);
    } else if (serviceTypeId == 2){
      DB(dbAddress).setUIntValue(keccak256("dentist/treatment-service/fee", userId, serviceId), fee);
    }
  }

  function initScanRequest (
    address dbAddress,
    uint scanAppointmentId
  )
    internal
    returns (uint scanRequestId)
  {
    scanRequestId = utilities.getArrayItemsCount(dbAddress, "scan-requests-count");

    require(DB(dbAddress).getUInt8Value(keccak256("scan-request/status", scanRequestId)) == 0);
    DB(dbAddress).setUInt8Value(keccak256("scan-request/status", scanRequestId), 1);
    DB(dbAddress).setUIntValue(keccak256("scan-request/created-on", scanRequestId), now);
    DB(dbAddress).setUIntValue(keccak256("scan-request/scan-service", scanRequestId), scanAppointmentId);
    utilities.addArrayItem(dbAddress, "scan-request", "scan-requests-count", scanRequestId); // scanRequestId is currently just there for counter purpose
    utilities.addIdArrayItem(dbAddress, scanAppointmentId, "scan-service/scan-request", "scan-service/scan-requests-count", scanRequestId); // scanAppointmentId is currently just there for counter purpose
  }

  // scan request status: 1 => active, 2 => expired, 3 => canceled, 4 => fulfilled, 5 => rejected
  // scan application status: 1 => pending, 2 => active, 3 => canceled, 4 => fulfilled, 5 => inactive
  function handleWritePatientScanRequest (
    address dbAddress,
    uint scanRequestId,
    address dentistId,
    address patientId,
    bytes32 appointmentDate,
    bytes32 scanTime,
    string scanComment
  )
    internal
  {
    require(DB(dbAddress).getUInt8Value(keccak256("scan-request/status", scanRequestId)) == 1);
    addPatientToScanRequest(dbAddress, scanRequestId, patientId, appointmentDate, scanTime, scanComment);
    decideWhetherToWriteDentistRequested(dbAddress, dentistId, scanRequestId);
  }

  function handleWritePatientScanRequestInsurance (
    address dbAddress,
    uint scanRequestId,
    bytes32 scanInsurance,
    bytes32 scanPolicyNumber,
    bytes32 scanPayerId,
    bytes32 scanMainSubscriber,
    string scanInsuranceAddress
  )
    internal
  {
    require(DB(dbAddress).getUInt8Value(keccak256("scan-request/status", scanRequestId)) == 1);
    addPatientToScanRequestInsurance(dbAddress, scanRequestId, scanInsurance, scanPolicyNumber, scanPayerId, scanMainSubscriber, scanInsuranceAddress);
  }

  function decideWhetherToWriteDentistRequested(address dbAddress, address dentistId, uint scanRequestId) internal {
    if (dentistId == 0x0)  {
      DB(dbAddress).setBooleanValue(keccak256("scan-request/is-general?", scanRequestId), true);
    } else {
      DB(dbAddress).setBooleanValue(keccak256("scan-request/is-general?", scanRequestId), false);
      DB(dbAddress).setAddressValue(keccak256("scan-request/dentist", scanRequestId), dentistId);
      utilities.addIdArrayItem(dbAddress, dentistId, "dentist/scan-request", "dentist/scan-requests-count", scanRequestId);
    }
  }

  function addPatientToScanRequest (
    address dbAddress,
    uint scanRequestId,
    address patientId,
    bytes32 appointmentDate,
    bytes32 scanTime,
    string scanComment
  )
    internal
  {
    utilities.addIdArrayItem(dbAddress, patientId, "patient/scan-request", "patient/scan-requests-count", scanRequestId);
    DB(dbAddress).setAddressValue(keccak256("scan-request/patient", scanRequestId), patientId);
    DB(dbAddress).setBytes32Value(keccak256("scan-request/appointment-date", scanRequestId), appointmentDate);
    DB(dbAddress).setBytes32Value(keccak256("scan-request/appointment-time", scanRequestId), scanTime);
    DB(dbAddress).setStringValue(keccak256("scan-request/appointment-comment", scanRequestId), scanComment);
  }

  function addPatientToScanRequestInsurance (
    address dbAddress,
    uint scanRequestId,
    bytes32 scanInsurance,
    bytes32 scanPolicyNumber,
    bytes32 scanPayerId,
    bytes32 scanMainSubscriber,
    string scanInsuranceAddress
  )
    internal
  {
    DB(dbAddress).setBytes32Value(keccak256("scan-request/appointment-insurance", scanRequestId), scanInsurance);
    DB(dbAddress).setBytes32Value(keccak256("scan-request/appointment-insurance-policy-number", scanRequestId), scanPolicyNumber);
    DB(dbAddress).setBytes32Value(keccak256("scan-request/appointment-insurance-payer-id", scanRequestId), scanPayerId);
    DB(dbAddress).setBytes32Value(keccak256("scan-request/appointment-insurance-main-subscriber", scanRequestId), scanMainSubscriber);
    DB(dbAddress).setStringValue(keccak256("scan-request/appointment-insurance-address", scanRequestId), scanInsuranceAddress);
  }

  function handleCancelPatientScanRequest (
    address dbAddress,
    address patientId,
    uint scanRequestId
  )
    internal
  {
    require(DB(dbAddress).getUInt8Value(keccak256("scan-request/status", scanRequestId)) == 1
      && DB(dbAddress).getAddressValue(keccak256("scan-request/patient", scanRequestId)) == patientId);

    DB(dbAddress).setUInt8Value(keccak256("scan-request/status", scanRequestId), 3);
  }

  function handleExpirePatientScanRequest (
    address dbAddress,
    uint scanRequestId
  )
    internal
  {
    require(DB(dbAddress).getUInt8Value(keccak256("scan-request/status", scanRequestId)) == 1);

    DB(dbAddress).setUInt8Value(keccak256("scan-request/status", scanRequestId), 2);
  }

  function handleAcceptPatientScanRequest (
    address dbAddress,
    address dentistId,
    address patientId,
    uint scanRequestId,
    uint quote,
    bytes32 scanDate,
    bytes32 scanTime,
    string comment
  )
    internal
  {
    require(DB(dbAddress).getAddressValue(keccak256("scan-request/dentist", scanRequestId)) == dentistId);
    writeScanApplication(dbAddress, dentistId, patientId, scanRequestId, quote, scanDate, scanTime, comment);
    DB(dbAddress).setBooleanValue(keccak256("scan-request/is-accepted?", scanRequestId), true);
  }

  function handleRejectPatientScanRequest (
    address dbAddress,
    address dentistId,
    address patientId,
    uint scanRequestId
  )
    internal
  {
    require(DB(dbAddress).getUInt8Value(keccak256("scan-request/status", scanRequestId)) == 1
      && DB(dbAddress).getAddressValue(keccak256("scan-request/dentist", scanRequestId)) == dentistId
      && DB(dbAddress).getAddressValue(keccak256("scan-request/patient", scanRequestId)) == patientId);

    DB(dbAddress).setUInt8Value(keccak256("scan-request/status", scanRequestId), 5);
  }

  function handleApplyToScanPatient (
    address dbAddress,
    address dentistId,
    address patientId,
    uint scanRequestId,
    uint quote,
    bytes32 scanDate,
    bytes32 scanTime,
    string comment
  )
    internal
  {
    writeScanApplication(dbAddress, dentistId, patientId, scanRequestId, quote, scanDate, scanTime, comment);
  }

  function writeScanApplication (
    address dbAddress,
    address dentistId,
    address patientId,
    uint scanRequestId,
    uint quote,
    bytes32 scanDate,
    bytes32 scanTime,
    string comment
  )
    internal
  {
    uint scanApplicationId = utilities.getArrayItemsCount(dbAddress, "scan-applications-count");
    require(DB(dbAddress).getUInt8Value(keccak256("scan-application/status", scanApplicationId)) == 0
      && DB(dbAddress).getUInt8Value(keccak256("scan-request/status", scanRequestId)) == 1
      && DB(dbAddress).getAddressValue(keccak256("scan-request/patient", scanRequestId)) == patientId);

    for (uint i = 0; i < scanApplicationId; i++) {
      var scanApplication = DB(dbAddress).getUIntValue(keccak256("dentist/scan-application", dentistId, i));
      var scanRequest = DB(dbAddress).getUIntValue(keccak256("scan-application/scan-request", scanApplication));
      if (scanRequest == scanRequestId
          && (DB(dbAddress).getUInt8Value(keccak256("scan-application/status", scanApplication)) == 1
          || DB(dbAddress).getUInt8Value(keccak256("scan-application/status", scanApplication)) == 2
          || DB(dbAddress).getUInt8Value(keccak256("scan-application/status", scanApplication)) == 4
          || DB(dbAddress).getUInt8Value(keccak256("scan-application/status", scanApplication)) == 5)) {
        return;
      }
    }

    uint scanServiceId = DB(dbAddress).getUIntValue(keccak256("scan-request/scan-service", scanRequestId));
    DB(dbAddress).setBooleanValue(keccak256("dentist/scan-request", dentistId, scanRequestId), true);
    initScanApplication(dbAddress, scanServiceId, scanRequestId, scanApplicationId);
    writeScanApplicationData(dbAddress, dentistId, patientId, scanApplicationId, quote, scanDate, scanTime, comment);
  }

  function initScanApplication (address dbAddress, uint scanServiceId, uint scanRequestId, uint scanApplicationId) internal {
    DB(dbAddress).setUInt8Value(keccak256("scan-application/status", scanApplicationId), 1);
    DB(dbAddress).setUIntValue(keccak256("scan-application/created-on", scanApplicationId), now);
    DB(dbAddress).setUIntValue(keccak256("scan-application/scan-request", scanApplicationId), scanRequestId);
    DB(dbAddress).setUIntValue(keccak256("scan-application/scan-service", scanApplicationId), scanServiceId);
    utilities.addArrayItem(dbAddress, "scan-application", "scan-applications-count", scanApplicationId); // scanApplicationId is currently just there for counter purpose
    utilities.addIdArrayItem(dbAddress, scanRequestId, "scan-request/scan-application", "scan-request/scan-applications-count", scanApplicationId);
  }

  function writeScanApplicationData (address dbAddress, address dentistId, address patientId, uint scanApplicationId, uint quote, bytes32 scanDate, bytes32 scanTime, string comment) internal {
    DB(dbAddress).setUIntValue(keccak256("scan-application/quote", scanApplicationId), quote);
    DB(dbAddress).setBytes32Value(keccak256("scan-application/appointment-date", scanApplicationId), scanDate);
    DB(dbAddress).setBytes32Value(keccak256("scan-application/appointment-time", scanApplicationId), scanTime);
    DB(dbAddress).setStringValue(keccak256("scan-application/comment", scanApplicationId), comment);
    DB(dbAddress).setAddressValue(keccak256("scan-application/dentist", scanApplicationId), dentistId);
    DB(dbAddress).setAddressValue(keccak256("scan-application/patient", scanApplicationId), patientId);
    utilities.addIdArrayItem(dbAddress, dentistId, "dentist/scan-application", "dentist/scan-applications-count", scanApplicationId);
    utilities.addIdArrayItem(dbAddress, patientId, "patient/scan-application", "patient/scan-applications-count", scanApplicationId);
  }

  function handleCancelDentistScanApplication (
    address dbAddress,
    address dentistId,
    address patientId,
    uint scanApplicationId
  )
    internal
  {
    require(DB(dbAddress).getUInt8Value(keccak256("scan-application/status", scanApplicationId)) == 1
      && DB(dbAddress).getAddressValue(keccak256("scan-application/dentist", scanApplicationId)) == dentistId
      && DB(dbAddress).getAddressValue(keccak256("scan-application/patient", scanApplicationId)) == patientId);

    DB(dbAddress).setUInt8Value(keccak256("scan-application/status", scanApplicationId), 3);
  }

  // case status: 1 => pending, 2 => treated, 3 => canceled
  function handleAcceptDentistScanApplication (
    address dbAddress,
    address dentistId,
    address patientId,
    uint scanApplicationId,
    uint paymentId,
    uint amount,
    uint quote
  )
    internal
  {
    uint caseId = utilities.getArrayItemsCount(dbAddress, "cases-count");
    DB(dbAddress).setUInt8Value(keccak256("payment/state", paymentId), 1);
    uint scanRequestId = DB(dbAddress).getUIntValue(keccak256("scan-application/scan-request", scanApplicationId));
    require(DB(dbAddress).getUInt8Value(keccak256("case/status", caseId)) == 0
      && DB(dbAddress).getUInt8Value(keccak256("scan-application/status", scanApplicationId)) == 1
      && DB(dbAddress).getUInt8Value(keccak256("scan-request/status", scanRequestId)) == 1
      && DB(dbAddress).getAddressValue(keccak256("scan-request/patient", scanRequestId)) == patientId
      && DB(dbAddress).getAddressValue(keccak256("scan-application/dentist", scanApplicationId)) == dentistId
      && DB(dbAddress).getAddressValue(keccak256("scan-application/patient", scanApplicationId)) == patientId);

    uint scanServiceId = DB(dbAddress).getUIntValue(keccak256("scan-application/scan-service", scanApplicationId));
    initCase(dbAddress, dentistId, patientId, scanServiceId, scanRequestId, scanApplicationId, caseId);
    writeCaseData(dbAddress, dentistId, patientId, caseId, paymentId, amount, quote);

    DB(dbAddress).setUInt8Value(keccak256("scan-request/status", scanRequestId), 4);
    DB(dbAddress).setUInt8Value(keccak256("scan-application/status", scanApplicationId), 4);
    deactivateEveryOtherScanApplications(dbAddress, scanRequestId, scanApplicationId);
  }

  function deactivateEveryOtherScanApplications (address dbAddress, uint scanRequestId, uint winningScanApplicationId) internal {
    uint count = utilities.getIdArrayItemsCount(dbAddress, scanRequestId, "scan-request/scan-applications-count");
    for (uint i = 0; i < count; i++) {
      var scanApplicationId = DB(dbAddress).getUIntValue(keccak256("scan-request/scan-application", scanRequestId, i));
      if (scanApplicationId != winningScanApplicationId) {
        DB(dbAddress).setUInt8Value(keccak256("scan-application/status", scanApplicationId), 5);
      }
    }
  }

  function initCase (address dbAddress, address dentistId, address patientId, uint scanServiceId, uint scanRequestId, uint scanApplicationId, uint caseId) internal {
    DB(dbAddress).setUInt8Value(keccak256("case/status", caseId), 1);
    DB(dbAddress).setUIntValue(keccak256("case/created-on", caseId), now);
    DB(dbAddress).setAddressValue(keccak256("case/dentist", caseId), dentistId);
    DB(dbAddress).setAddressValue(keccak256("case/patient", caseId), patientId);
    DB(dbAddress).setUIntValue(keccak256("case/scan-service", caseId), scanServiceId);
    DB(dbAddress).setUIntValue(keccak256("case/scan-request", caseId), scanRequestId);
    DB(dbAddress).setUIntValue(keccak256("scan-request/case", scanRequestId), caseId);
    DB(dbAddress).setBooleanValue(keccak256("scan-request/has-case?", scanRequestId), true);
    DB(dbAddress).setUIntValue(keccak256("case/scan-application", caseId), scanApplicationId);
    DB(dbAddress).setUIntValue(keccak256("scan-application/case", scanApplicationId), caseId);
    DB(dbAddress).setBooleanValue(keccak256("scan-application/has-case?", scanApplicationId), true);
    utilities.addArrayItem(dbAddress, "case", "cases-count", caseId); // caseId is currently just there for counter purpose
  }

  function writeCaseData (address dbAddress, address dentistId, address patientId, uint caseId, uint paymentId, uint amount, uint quote) internal {
    DB(dbAddress).setUIntValue(keccak256("case/amount", caseId), amount);
    DB(dbAddress).setUIntValue(keccak256("case/quote", caseId), quote);
    DB(dbAddress).setUIntValue(keccak256("payment/amount", paymentId), amount);
    DB(dbAddress).setUIntValue(keccak256("payment/quote", paymentId), quote);
    DB(dbAddress).setBooleanValue(keccak256("case/paid", caseId), true);
    DB(dbAddress).setUIntValue(keccak256("case/payment", caseId), paymentId);
    DB(dbAddress).setUIntValue(keccak256("payment/case", paymentId), caseId);
    utilities.addIdArrayItem(dbAddress, dentistId, "dentist/case", "dentist/cases-count", caseId);
    utilities.addIdArrayItem(dbAddress, patientId, "patient/case", "patient/cases-count", caseId);
    utilities.addArrayItem(dbAddress, "payment", "payments-count", paymentId); // paymentId is currently just there for counter purpose
  }

  // treatment request status: 1 => pending, 2 => fulfilled, 3 => canceled
  // treatment application status: 1 => pending, 2 => active, 3 => canceled, 4 => fulfilled, 5 => inactive
  function handleWritePatientTreatmentRequest (
    address dbAddress,
    uint treatmentRequestId,
    address patientId,
    string scanResults,
    string comment
  )
    internal
  {
    uint caseId = DB(dbAddress).getUIntValue(keccak256("treatment-request/case", treatmentRequestId));

    for (uint i = 0; i < treatmentRequestId; i++) {
      var treatmentRequest = DB(dbAddress).getUIntValue(keccak256("patient/treatment-request", patientId, i));
      var caseItem = DB(dbAddress).getUIntValue(keccak256("treatment-request/case", treatmentRequest));
      if (caseItem == caseId
          && (DB(dbAddress).getUInt8Value(keccak256("treatment-request/status", treatmentRequest)) == 1
          || DB(dbAddress).getUInt8Value(keccak256("treatment-request/status", treatmentRequest)) == 2)) {
        return;
      }
    }

    addPatientToTreatmentRequest(dbAddress, treatmentRequestId, patientId, scanResults, comment);
  }

  function handleWritePatientTreatmentRequestInsurance (
    address dbAddress,
    uint treatmentRequestId,
    bytes32 treatmentInsurance,
    bytes32 treatmentPolicyNumber,
    bytes32 treatmentPayerId,
    bytes32 treatmentMainSubscriber,
    string treatmentInsuranceAddress
  )
    internal
  {
    addPatientToTreatmentRequestInsurance(dbAddress, treatmentRequestId, treatmentInsurance, treatmentPolicyNumber, treatmentPayerId, treatmentMainSubscriber, treatmentInsuranceAddress);
  }

  function getCaseIfNecessary (address dbAddress, bool hasCaseId, uint caseId) internal view returns (uint newCaseId) {
    if (!hasCaseId) {
      newCaseId = utilities.getArrayItemsCount(dbAddress, "cases-count");
      DB(dbAddress).setUInt8Value(keccak256("case/status", newCaseId), 1);
    } else {
      newCaseId = caseId;
    }
  }

  function initTreatmentRequest (address dbAddress, bool hasCaseId, uint caseId) internal view returns (uint treatmentRequestId) {
    caseId = getCaseIfNecessary(dbAddress, hasCaseId, caseId);
    treatmentRequestId = utilities.getArrayItemsCount(dbAddress, "treatment-requests-count");
    require(DB(dbAddress).getUInt8Value(keccak256("treatment-request/status", treatmentRequestId)) == 0);

    DB(dbAddress).setUInt8Value(keccak256("treatment-request/status", treatmentRequestId), 1);
    DB(dbAddress).setUIntValue(keccak256("treatment-request/created-on", treatmentRequestId), now);
    DB(dbAddress).setUIntValue(keccak256("treatment-request/case", treatmentRequestId), caseId);
    utilities.addArrayItem(dbAddress, "treatment-request", "treatment-requests-count", treatmentRequestId); // caseId is currently just there for counter purpose
    utilities.addIdArrayItem(dbAddress, caseId, "case/treatment-request", "case/treatment-requests-count", treatmentRequestId);
  }

  function addPatientToTreatmentRequest (
    address dbAddress,
    uint treatmentRequestId,
    address patientId,
    string scanResults,
    string comment
  )
    internal
  {
    utilities.addIdArrayItem(dbAddress, patientId, "patient/treatment-request", "patient/treatment-requests-count", treatmentRequestId);
    DB(dbAddress).setAddressValue(keccak256("treatment-request/patient", treatmentRequestId), patientId);
    DB(dbAddress).setStringValue(keccak256("treatment-request/scan-results", treatmentRequestId), scanResults);
    DB(dbAddress).setStringValue(keccak256("treatment-request/comment", treatmentRequestId), comment);
  }

  function addPatientToTreatmentRequestInsurance (
    address dbAddress,
    uint treatmentRequestId,
    bytes32 treatmentInsurance,
    bytes32 treatmentPolicyNumber,
    bytes32 treatmentPayerId,
    bytes32 treatmentMainSubscriber,
    string treatmentInsuranceAddress
  )
    internal
  {
    DB(dbAddress).setBytes32Value(keccak256("treatment-request/appointment-insurance", treatmentRequestId), treatmentInsurance);
    DB(dbAddress).setBytes32Value(keccak256("treatment-request/appointment-insurance-policy-number", treatmentRequestId), treatmentPolicyNumber);
    DB(dbAddress).setBytes32Value(keccak256("treatment-request/appointment-insurance-payer-id", treatmentRequestId), treatmentPayerId);
    DB(dbAddress).setBytes32Value(keccak256("treatment-request/appointment-insurance-main-subscriber", treatmentRequestId), treatmentMainSubscriber);
    DB(dbAddress).setStringValue(keccak256("treatment-request/appointment-insurance-address", treatmentRequestId), treatmentInsuranceAddress);
  }

  function handleCancelPatientTreatmentRequest (
    address dbAddress,
    address patientId,
    uint treatmentRequestId
  )
    internal
  {
    require(DB(dbAddress).getUInt8Value(keccak256("treatment-request/status", treatmentRequestId)) == 1
      && DB(dbAddress).getAddressValue(keccak256("treatment-request/patient", treatmentRequestId)) == patientId);

    DB(dbAddress).setUInt8Value(keccak256("treatment-request/status", treatmentRequestId), 3);
  }

  function handleApplyToTreatPatient(
    address dbAddress,
    address dentistId,
    address patientId,
    uint treatmentRequestId,
    uint quote,
    bytes32 treatmentDate,
    bytes32 treatmentTime,
    string comment
  )
    internal
  {
    writeTreatmentApplication(dbAddress, dentistId, patientId, treatmentRequestId, quote, treatmentDate, treatmentTime, comment);
  }

  function writeTreatmentApplication (
    address dbAddress,
    address dentistId,
    address patientId,
    uint treatmentRequestId,
    uint quote,
    bytes32 treatmentDate,
    bytes32 treatmentTime,
    string comment
  )
    internal
  {
    uint treatmentApplicationId = utilities.getArrayItemsCount(dbAddress, "treatment-applications-count");
    require(DB(dbAddress).getUInt8Value(keccak256("treatment-application/status", treatmentApplicationId)) == 0
      && DB(dbAddress).getUInt8Value(keccak256("treatment-request/status", treatmentRequestId)) == 1
      && DB(dbAddress).getAddressValue(keccak256("treatment-request/patient", treatmentRequestId)) == patientId);

    for (uint i = 0; i < treatmentApplicationId; i++) {
      var treatmentApplication = DB(dbAddress).getUIntValue(keccak256("dentist/treatment-application", dentistId, i));
      var treatmentRequest = DB(dbAddress).getUIntValue(keccak256("treatment-application/treatment-request", treatmentApplication));
      if (treatmentRequest == treatmentRequestId
          && (DB(dbAddress).getUInt8Value(keccak256("treatment-application/status", treatmentApplication)) == 1
          || DB(dbAddress).getUInt8Value(keccak256("treatment-application/status", treatmentApplication)) == 2
          || DB(dbAddress).getUInt8Value(keccak256("treatment-application/status", treatmentApplication)) == 4
          || DB(dbAddress).getUInt8Value(keccak256("treatment-application/status", treatmentApplication)) == 5)) {
        return;
      }
    }

    DB(dbAddress).setBooleanValue(keccak256("dentist/treatment-request", dentistId, treatmentRequestId), true);
    initTreatmentApplication(dbAddress, treatmentRequestId, treatmentApplicationId);
    writeTreatmentApplicationData(dbAddress, dentistId, patientId, treatmentRequestId, treatmentApplicationId, quote, treatmentDate, treatmentTime, comment);
  }

  function initTreatmentApplication (address dbAddress, uint treatmentRequestId, uint treatmentApplicationId) internal {
    DB(dbAddress).setUInt8Value(keccak256("treatment-application/status", treatmentApplicationId), 1);
    DB(dbAddress).setUIntValue(keccak256("treatment-application/created-on", treatmentApplicationId), now);
    DB(dbAddress).setUIntValue(keccak256("treatment-application/treatment-request", treatmentApplicationId), treatmentRequestId);
    utilities.addArrayItem(dbAddress, "treatment-application", "treatment-applications-count", treatmentApplicationId); // treatmentRequestId is currently just there for counter purpose
  }

  function writeTreatmentApplicationData (address dbAddress, address dentistId, address patientId, uint treatmentRequestId, uint treatmentApplicationId, uint quote, bytes32 treatmentDate, bytes32 treatmentTime, string comment) internal {
    DB(dbAddress).setUIntValue(keccak256("treatment-application/quote", treatmentApplicationId), quote);
    DB(dbAddress).setBytes32Value(keccak256("treatment-application/appointment-date", treatmentApplicationId), treatmentDate);
    DB(dbAddress).setBytes32Value(keccak256("treatment-application/appointment-time", treatmentApplicationId), treatmentTime);
    DB(dbAddress).setStringValue(keccak256("treatment-application/comment", treatmentApplicationId), comment);
    DB(dbAddress).setAddressValue(keccak256("treatment-application/dentist", treatmentApplicationId), dentistId);
    DB(dbAddress).setAddressValue(keccak256("treatment-application/patient", treatmentApplicationId), patientId);
    utilities.addIdArrayItem(dbAddress, dentistId, "dentist/treatment-application", "dentist/treatment-applications-count", treatmentApplicationId);
    utilities.addIdArrayItem(dbAddress, patientId, "patient/treatment-application", "patient/treatment-applications-count", treatmentApplicationId);
    utilities.addIdArrayItem(dbAddress, treatmentRequestId, "treatment-request/treatment-application", "treatment-request/treatment-applications-count", treatmentApplicationId);
  }

  function handleCancelDentistTreatmentApplication (
    address dbAddress,
    address dentistId,
    address patientId,
    uint treatmentApplicationId
  )
    internal
  {
    require(DB(dbAddress).getUInt8Value(keccak256("treatment-application/status", treatmentApplicationId)) == 1
      && DB(dbAddress).getAddressValue(keccak256("treatment-application/dentist", treatmentApplicationId)) == dentistId
      && DB(dbAddress).getAddressValue(keccak256("treatment-application/patient", treatmentApplicationId)) == patientId);

    DB(dbAddress).setUInt8Value(keccak256("treatment-application/status", treatmentApplicationId), 3);
  }

  // treatment status: 1 => pending, 2 => done, 3 => canceled
  function handleAcceptDentistTreatmentApplication (
    address dbAddress,
    address dentistId,
    address patientId,
    uint treatmentApplicationId,
    uint paymentId,
    uint amount,
    uint quote
  )
    internal
  {
    uint treatmentId = utilities.getArrayItemsCount(dbAddress, "treatments-count");
    DB(dbAddress).setUInt8Value(keccak256("payment/state", paymentId), 1);
    uint treatmentRequestId = DB(dbAddress).getUIntValue(keccak256("treatment-application/treatment-request", treatmentApplicationId));
    require(DB(dbAddress).getUInt8Value(keccak256("treatment/status", treatmentId)) == 0
      && DB(dbAddress).getUInt8Value(keccak256("treatment-application/status", treatmentApplicationId)) == 1
      && DB(dbAddress).getUInt8Value(keccak256("treatment-request/status", treatmentRequestId)) == 1
      && DB(dbAddress).getAddressValue(keccak256("treatment-request/patient", treatmentRequestId)) == patientId
      && DB(dbAddress).getAddressValue(keccak256("treatment-application/dentist", treatmentApplicationId)) == dentistId
      && DB(dbAddress).getAddressValue(keccak256("treatment-application/patient", treatmentApplicationId)) == patientId);

    initTreatment(dbAddress, dentistId, patientId, treatmentRequestId, treatmentApplicationId, treatmentId);
    writeTreatmentData(dbAddress, dentistId, patientId, treatmentId, paymentId, amount, quote);

    DB(dbAddress).setUInt8Value(keccak256("treatment-request/status", treatmentRequestId), 2);
    DB(dbAddress).setUInt8Value(keccak256("treatment-application/status", treatmentApplicationId), 4);
    deactivateEveryOtherTreatmentApplications(dbAddress, treatmentRequestId, treatmentApplicationId);
  }

  function deactivateEveryOtherTreatmentApplications (address dbAddress, uint treatmentRequestId, uint winningTreatmentApplicationId) internal {
    uint count = utilities.getIdArrayItemsCount(dbAddress, treatmentRequestId, "treatment-request/treatment-applications-count");
    for (uint i = 0; i < count; i++) {
      var treatmentApplicationId = DB(dbAddress).getUIntValue(keccak256("treatment-request/treatment-application", treatmentRequestId, i));
      if (treatmentApplicationId != winningTreatmentApplicationId) {
        DB(dbAddress).setUInt8Value(keccak256("treatment-application/status", treatmentApplicationId), 5);
      }
    }
  }

  function initTreatment (address dbAddress, address dentistId, address patientId, uint treatmentRequestId, uint treatmentApplicationId, uint treatmentId) internal {
    DB(dbAddress).setUInt8Value(keccak256("treatment/status", treatmentId), 1);
    DB(dbAddress).setUIntValue(keccak256("treatment/created-on", treatmentId), now);
    DB(dbAddress).setAddressValue(keccak256("treatment/dentist", treatmentId), dentistId);
    DB(dbAddress).setAddressValue(keccak256("treatment/patient", treatmentId), patientId);
    DB(dbAddress).setUIntValue(keccak256("treatment/treatment-request", treatmentId), treatmentRequestId);
    DB(dbAddress).setUIntValue(keccak256("treatment-request/treatment", treatmentRequestId), treatmentId);
    DB(dbAddress).setBooleanValue(keccak256("treatment-request/has-treatment?", treatmentRequestId), true);
    DB(dbAddress).setUIntValue(keccak256("treatment/treatment-application", treatmentId), treatmentApplicationId);
    DB(dbAddress).setUIntValue(keccak256("treatment-application/treatment", treatmentApplicationId), treatmentId);
    DB(dbAddress).setBooleanValue(keccak256("treatment-application/has-treatment?", treatmentApplicationId), true);
    utilities.addArrayItem(dbAddress, "treatment", "treatments-count", treatmentId); // treatmentId is currently just there for counter purpose
  }

  function writeTreatmentData (address dbAddress, address dentistId, address patientId, uint treatmentId, uint paymentId, uint amount, uint quote) internal {
    DB(dbAddress).setUIntValue(keccak256("treatment/amount", treatmentId), amount);
    DB(dbAddress).setUIntValue(keccak256("treatment/quote", treatmentId), quote);
    DB(dbAddress).setUIntValue(keccak256("payment/amount", paymentId), amount);
    DB(dbAddress).setUIntValue(keccak256("payment/quote", paymentId), quote);
    DB(dbAddress).setBooleanValue(keccak256("treatment/paid", treatmentId), true);
    DB(dbAddress).setUIntValue(keccak256("treatment/payment", treatmentId), paymentId);
    DB(dbAddress).setUIntValue(keccak256("payment/treatment", paymentId), treatmentId);
    utilities.addIdArrayItem(dbAddress, dentistId, "dentist/treatment", "dentist/treatments-count", treatmentId);
    utilities.addIdArrayItem(dbAddress, patientId, "patient/treatment", "patient/treatments-count", treatmentId);
    utilities.addArrayItem(dbAddress, "payment", "payments-count", paymentId); // paymentId is currently just there for counter purpose
  }

  function handleCancelPatientTreatment (
    address dbAddress,
    address dentistId,
    address patientId,
    uint treatmentId
  )
    internal
  {
    require(DB(dbAddress).getUInt8Value(keccak256("treatment/status", treatmentId)) == 1
      && DB(dbAddress).getAddressValue(keccak256("treatment/dentist", treatmentId)) == dentistId
      && DB(dbAddress).getAddressValue(keccak256("treatment/patient", treatmentId)) == patientId);

    DB(dbAddress).setUInt8Value(keccak256("treatment/status", treatmentId), 3);
  }

  function handleMarkPatientTreatmentDone (
    address dbAddress,
    address dentistId,
    address patientId,
    uint treatmentId
  )
    internal
  {
    require(DB(dbAddress).getUInt8Value(keccak256("treatment/status", treatmentId)) == 1
      && DB(dbAddress).getAddressValue(keccak256("treatment/dentist", treatmentId)) == dentistId
      && DB(dbAddress).getAddressValue(keccak256("treatment/patient", treatmentId)) == patientId);

    DB(dbAddress).setUInt8Value(keccak256("treatment/status", treatmentId), 2);
  }
}
