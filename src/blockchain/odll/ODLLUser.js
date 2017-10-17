// import ODLLUserContract from '../../../build/contracts/ODLLUser.json'
import blockchainManager from '../BlockchainManager'

let odllUser = null

class ODLLUser {
  constructor () {
    odllUser = odllUser || this
    return odllUser
  }

  addOfficialToODLL (state = null, data = {}) {
    return blockchainManager.querySmartContract({
      smartContractMethod: 'addOfficialToODLL',
      smartContractMethodParams: (coinbase) => [...(Object.values(data.userObject)), {from: coinbase}],
      state,
      smartContractResolve: result => data,
      smartContractReject: error => error
    })
  }

  writeUser (state = null, data = {}) {
    return blockchainManager.querySmartContract({
      smartContractMethod: 'writeUser',
      smartContractMethodParams: (coinbase) => [...(Object.values(data.userObject)), {from: coinbase, gas: 4444444}],
      state,
      smartContractResolve: result => data,
      smartContractReject: error => error
    })
  }

  getUserDataFromTheBlockchain (state = null) {
    return new Promise((resolve, reject) => {
      const userObject = {}
      odllUser.getUserIdentityData(state)
      .then((result) => {
        Object.assign(userObject, result)
        odllUser.getUserContactData(state)
        .then((result) => {
          Object.assign(userObject, result)
          odllUser.getUserPersonalData(state)
          .then((result) => {
            Object.assign(userObject, result)
            resolve(userObject)
          })
          .catch(error => reject(error))
        })
        .catch(error => reject(error))
      })
      .catch(error => reject(error))
    })
  }

  getUserIdentityData (state = null, userId = null) {
    return blockchainManager.querySmartContract({
      smartContractMethod: 'getUserIdentityData',
      smartContractMethodParams: (coinbase) => [userId || coinbase, {from: coinbase}],
      state,
      smartContractResolve: result => odllUser.getUserObject(state, result, ['type', 'name', 'email', 'gravatar']),
      smartContractReject: (error) => ({
        error,
        isValid: true,
        warningMessage: "We've encountered a problem fetching your identity information from the blockchain. Please do try again in a few minutes."
      })
    })
  }

  getUserContactData (state = null, userId = null) {
    return blockchainManager.querySmartContract({
      smartContractMethod: 'getUserContactData',
      smartContractMethodParams: (coinbase) => [userId || coinbase, {from: coinbase}],
      state,
      smartContractResolve: result => odllUser.getUserObject(state, result, ['street', 'city', 'phoneNumber', 'state', 'zipCode', 'country']),
      smartContractReject: (error) => ({
        error,
        isValid: true,
        warningMessage: "We've encountered a problem fetching your contact information from the blockchain. Please do try again in a few minutes."
      })
    })
  }

  getUserPersonalData (state = null, userId = null) {
    return blockchainManager.querySmartContract({
      smartContractMethod: 'getUserPersonalData',
      smartContractMethodParams: (coinbase) => [userId || coinbase, {from: coinbase}],
      state,
      smartContractResolve: result => odllUser.getUserObject(state, result, ['gender', 'socialSecurityNumber', 'birthday']),
      smartContractReject: (error) => ({
        error,
        isValid: true,
        warningMessage: "We've encountered a problem fetching your personal information from the blockchain. Please do try again in a few minutes."
      })
    })
  }

  getDentistFeeData (state = null, dataObject = {}) {
    const userId = dataObject.dentistId
    return blockchainManager.querySmartContract({
      smartContractMethod: 'getDentistFeeData',
      smartContractMethodParams: (coinbase) => [dataObject.serviceTypeId, dataObject.serviceId, userId || coinbase, {from: coinbase}],
      state,
      smartContractResolve: result => ({fee: result}),
      smartContractReject: (error) => ({
        error,
        isValid: true,
        warningMessage: "We've encountered a problem getting dentist fee from the blockchain. Please do try again in a few minutes."
      })
    })
  }

  getDentistRatingData (state = null, userId = null) {
    return blockchainManager.querySmartContract({
      smartContractMethod: 'getDentistRatingData',
      smartContractMethodParams: (coinbase) => [userId || coinbase, {from: coinbase}],
      state,
      smartContractResolve: result => ({rating: result}),
      smartContractReject: (error) => ({
        error,
        isValid: true,
        warningMessage: "We've encountered a problem getting dentist ratings from the blockchain. Please do try again in a few minutes."
      })
    })
  }

  getUserObject (state, results, keys) {
    const arrayResult = state && state.web3 && state.web3.instance && results && results.length > 0 ? results : []
    const userObject = keys.reduce((hash, key, index) => {
      hash[key] = arrayResult[index] ? arrayResult[index].toString() : ''
      return hash
    }, {})

    return userObject
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
      state: 0,
      zipCode: '',
      country: '',
      phoneNumber: '',
      socialSecurityNumber: '',
      areaNumber: '',
      groupNumber: '',
      sequenceNumber: '',
      day: '',
      month: '',
      year: '',
      birthday: '',
      gender: '',
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
}

odllUser = new ODLLUser()
export default odllUser
