pragma solidity 0.4.18;
import "./Restrictor.sol";
import "../lib/odll/userManager.sol";

contract ScanRequestWriter2 is Restrictor {
  function ScanRequestWriter2(address _dbAddress) public {
    require(_dbAddress != 0x0);
    dbAddress = _dbAddress;
  }

  // Scan Request
  function cancelScanRequest (
    uint scanRequestId
  )
    external
    onlyPermittedSmartContract
  {
    userManager.cancelPatientScanRequest(dbAddress, msg.sender, scanRequestId);
  }

  function expireScanRequest (
    uint scanRequestId
  )
    external
    onlyPermittedSmartContract
  {
    userManager.expirePatientScanRequest(dbAddress, scanRequestId);
  }

  function acceptScanRequest (
    address patientId,
    uint scanRequestId,
    uint quote,
    bytes32 scanDate,
    bytes32 scanTime,
    string comment
  )
    external
    onlyPermittedSmartContract
  {
    userManager.acceptPatientScanRequest(dbAddress, msg.sender, patientId, scanRequestId, quote, scanDate, scanTime, comment);
  }

  function rejectScanRequest (
    address patientId,
    uint scanRequestId
  )
    external
    onlyPermittedSmartContract
  {
    userManager.rejectPatientScanRequest(dbAddress, msg.sender, patientId, scanRequestId);
  }
}
