import DB from '../../../build/contracts/DB.json'
import UserWriter from '../../../build/contracts/UserWriter.json'
import UserReader from '../../../build/contracts/UserReader.json'
import ServiceWriter from '../../../build/contracts/ServiceWriter.json'
import ServiceReader from '../../../build/contracts/ServiceReader.json'
import ScanRequestWriter from '../../../build/contracts/ScanRequestWriter.json'
import ScanRequestWriter2 from '../../../build/contracts/ScanRequestWriter2.json'
import ScanRequestReader from '../../../build/contracts/ScanRequestReader.json'
import ScanRequestReader2 from '../../../build/contracts/ScanRequestReader2.json'
import ScanApplicationWriter from '../../../build/contracts/ScanApplicationWriter.json'
import ScanApplicationWriter2 from '../../../build/contracts/ScanApplicationWriter2.json'
import ScanApplicationReader from '../../../build/contracts/ScanApplicationReader.json'
import TreatmentRequestWriter from '../../../build/contracts/TreatmentRequestWriter.json'
import TreatmentRequestWriter2 from '../../../build/contracts/TreatmentRequestWriter2.json'
import TreatmentRequestReader from '../../../build/contracts/TreatmentRequestReader.json'
import TreatmentRequestReader2 from '../../../build/contracts/TreatmentRequestReader2.json'
import TreatmentApplicationWriter from '../../../build/contracts/TreatmentApplicationWriter.json'
import TreatmentApplicationWriter2 from '../../../build/contracts/TreatmentApplicationWriter2.json'
import TreatmentApplicationReader from '../../../build/contracts/TreatmentApplicationReader.json'
import PostApplicationReader from '../../../build/contracts/PostApplicationReader.json'
import PostApplicationReader2 from '../../../build/contracts/PostApplicationReader2.json'
import blockchainManager from '../BlockchainManager'
import {getObjectFromResponse, getSlicedAddressString, getSoliditySha3ForId, getGravatarFor} from '../utilities'
// import {EXCHANGE_RATE_API} from '../../util/constants'
import states from '../../../static/json/states/states.json'

let userManager = null

class Manager {
  constructor () {
    userManager = userManager || this
    return userManager
  }

  getContractToUse () {
    return {
      UserWriter,
      UserReader,
      ServiceWriter,
      ServiceReader,
      ScanRequestWriter,
      ScanRequestWriter2,
      ScanRequestReader,
      ScanRequestReader2,
      ScanApplicationWriter,
      ScanApplicationWriter2,
      ScanApplicationReader,
      TreatmentRequestWriter,
      TreatmentRequestWriter2,
      TreatmentRequestReader,
      TreatmentRequestReader2,
      TreatmentApplicationWriter,
      TreatmentApplicationWriter2,
      TreatmentApplicationReader,
      PostApplicationReader,
      PostApplicationReader2
    }
  }

  writeData (state = null, data = {}) {
    const blockchainData = Object.assign({}, data)
    const contractToUse = blockchainData.contractIndexToUse ? userManager.getContractToUse()[blockchainData.contractIndexToUse] : null
    const blockchainMethodName = blockchainData.methodName

    delete blockchainData.contractIndexToUse
    delete blockchainData.methodName
    return blockchainManager.querySmartContract({
      contractToUse: contractToUse || UserWriter,
      smartContractMethod: blockchainMethodName,
      smartContractMethodParams: (coinbase) => [...(Object.values(blockchainData)), {from: coinbase}],
      state,
      smartContractResolve: result => data,
      smartContractReject: error => error
    })
  }

  getUserDataFromTheBlockchain (state = null, userParams = {}) {
    return new Promise((resolve, reject) => {
      const userObject = {}
      userManager.getUserData(state, userParams.userId, userParams)
      .then((result) => {
        Object.assign(userObject, result)
        userManager.refineUserData(userObject, () => {
          resolve(userObject)
        })
      })
      .catch(error => reject(error))
    })
  }

  getUserData (state = null, userId = null, userObject = {}) {
    return blockchainManager.querySmartContract({
      contractToUse: DB,
      smartContractMethod: 'getEntityList',
      smartContractMethodParams: (coinbase) => {
        userId = userId || coinbase
        return [userObject.recordFields || userManager.userRecordFields(state, userId), userObject.recordFieldTypes || userManager.userRecordFieldTypes(), {from: coinbase}]
      },
      state,
      smartContractResolve: result => {
        const userData = getObjectFromResponse(state, result, 1, userObject.keys || userManager.userKeys(), userObject.recordFieldTypes || userManager.userRecordFieldTypes())[0]
        userData.coinbase = userData.coinbase || userId
        return userData
      },
      smartContractReject: (error) => ({
        error,
        isValid: true,
        warningMessage: "We've encountered a problem fetching your identity information from the blockchain. Please do try again in a few minutes."
      })
    })
  }

  refineUserData (userObject, callback = null) {
    let userState = userObject.state && Number(userObject.state) !== 0 ? states[Number(userObject.state)].name : ''
    let address = userObject.street || userObject.city || userState ? `${userObject.street} ${userObject.city} ${userState}` : ''
    Object.assign(userObject, { address })
    getGravatarFor({
      email: userObject.email,
      coinbase: userObject.coinbase
    })
    .then((avatarCanvas) => {
      userObject.avatarCanvas = avatarCanvas
      if (callback) callback(userObject)
    })
  }

  // acceptScanApplication (state = null, data = {}) {
  //   const quoteInEther = fetch(EXCHANGE_RATE_API)
  //   .then(response => response.json())
  //   .then((JSONResponse) => {
  //     const USDExchange = JSONResponse[0].price_usd
  //     return (data.requestObject.quote / USDExchange)
  //   })
  //   .catch((e) => console.error(e))
  //
  //   return blockchainManager.querySmartContract({
  //     smartContractMethod: 'acceptScanApplication',
  //     smartContractMethodParams: (coinbase) => [...(Object.values(data.requestObject)), {from: coinbase, value: state.web3.instance().toWei(quoteInEther, 'ether')}],
  //     state,
  //     smartContractResolve: result => data,
  //     smartContractReject: error => error
  //   })
  // }

  fetchUserDentists (state = null, userId = null) {
    return blockchainManager.querySmartContract({
      contractToUse: UserReader,
      smartContractMethod: 'fetchUserDentists',
      smartContractMethodParams: (coinbase) => [userId || coinbase, {from: coinbase}],
      state,
      smartContractResolve: result => getObjectFromResponse(state, result, ['dentistsIds']),
      smartContractReject: (error) => ({
        error,
        isValid: true,
        warningMessage: "We've encountered a problem fetching your dentists from the blockchain. Please do try again in a few minutes."
      })
    })
  }

  defaultUserObject () {
    return {
      type: '0',
      lastName: '',
      firstName: '',
      middleName: '',
      name: '',
      email: '',
      gravatar: '',
      street: '',
      city: '',
      state: '',
      zipCode: '',
      country: '',
      phoneNumber: '',
      // socialSecurityNumber: '',
      areaNumber: '',
      groupNumber: '',
      sequenceNumber: '',
      day: '',
      month: '',
      year: '',
      birthday: '',
      gender: '',
      dentistsIds: [],
      hasWeb3InjectedBrowser: false,
      hasCoinbase: false,
      isConnectedToODLLNetwork: false,
      coinbase: '',
      isValid: false,
      isPatient: false,
      canBeNewPatient: false,
      patientable: false,
      isDentist: false,
      isODLLAdmin: false,
      isODLLManager: false,
      warningMessage: ''
    }
  }

  userKeys () {
    return [
      'type',
      'status',
      'name',
      'email',
      'gravatar',
      'street',
      'city',
      'state',
      'zipCode',
      'country',
      'phoneNumber',
      // 'socialSecurityNumber',
      'birthday',
      'gender',
      'averageRating',
      'isODLLDentist'
    ]
  }

  userRecordFields (state, userId) {
    userId = getSlicedAddressString(state, userId)

    return [
      getSoliditySha3ForId(state, 'user/type', userId),
      getSoliditySha3ForId(state, 'user/status', userId),
      getSoliditySha3ForId(state, 'user/name', userId),
      getSoliditySha3ForId(state, 'user/email', userId),
      getSoliditySha3ForId(state, 'user/gravatar', userId),
      getSoliditySha3ForId(state, 'user/street', userId),
      getSoliditySha3ForId(state, 'user/city', userId),
      getSoliditySha3ForId(state, 'user/state', userId),
      getSoliditySha3ForId(state, 'user/zip-code', userId),
      getSoliditySha3ForId(state, 'user/country', userId),
      getSoliditySha3ForId(state, 'user/phone-number', userId),
      // getSoliditySha3ForId(state, 'user/social-security-number', userId),
      getSoliditySha3ForId(state, 'user/birthday', userId),
      getSoliditySha3ForId(state, 'user/gender', userId),
      getSoliditySha3ForId(state, 'dentist/average-rating', userId),
      getSoliditySha3ForId(state, 'user/is-odll-dentist?', userId)
    ]
  }

  userRecordFieldTypes () {
    // types: 1 => boolean, 2 => uint8, 3 => uint, 4 => address, 5 => bytes32, 7 => string
    return [2, 2, 7, 7, 5, 5, 5, 3, 5, 3, 5, 5, 2, 2, 1]
  }
}

userManager = new Manager()
export default userManager
