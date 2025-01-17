pragma solidity 0.4.18;

import "./Restrictor.sol";
import "../lib/odll/userManager.sol";

contract ScanRequestReader is Restrictor {

  function ScanRequestReader (address _dbAddress) public {
    require(_dbAddress != 0x0);
    dbAddress = _dbAddress;
  }

  function fetchScanRequestsForPatient (
    address patientId,
    uint offset, // starting from offset: 0-based
    uint limit, // not more than limit
    uint seed // seed value to give the illusion of randomisation
  )
    external
    view
    returns (
      uint,
      uint[]
    )
  {
    return userManager.fetchPatientScanRequests(dbAddress, patientId, offset, limit, seed);
  }

  function fetchAcceptedScanRequestsForPatient (
    address patientId,
    uint offset, // starting from offset: 0-based
    uint limit, // not more than limit
    uint seed // seed value to give the illusion of randomisation
  )
    external
    view
    returns (
      uint,
      uint[]
    )
  {
    return userManager.fetchPatientAcceptedScanRequests(dbAddress, patientId, offset, limit, seed);
  }

  function fetchDirectScanRequestsForDentist (
    address dentistId,
    uint offset, // starting from offset: 0-based
    uint limit, // not more than limit
    uint seed // seed value to give the illusion of randomisation
  )
    external
    view
    returns(
      uint,
      uint[]
    )
  {
    return userManager.fetchDentistDirectScanRequests(dbAddress, dentistId, offset, limit, seed);
  }

  function fetchAcceptedScanRequestsForDentist (
    address dentistId,
    uint offset, // starting from offset: 0-based
    uint limit, // not more than limit
    uint seed // seed value to give the illusion of randomisation
  )
    external
    view
    returns (
      uint,
      uint[]
    )
  {
    return userManager.fetchDentistAcceptedScanRequests(dbAddress, dentistId, offset, limit, seed);
  }
}
