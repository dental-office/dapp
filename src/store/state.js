export default {
  currentRoute: null,
  currentView: null,
  web3: {
    address: '',
    coinbase: '',
    error: null,
    instance: null,
    isInjected: false,
    networkId: ''
  },
  user: {
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
  },
  isDAppReady: false,
  isValidUserBut: '0',
  originalIsValidUserBut: '0',
  searchSeed: {
    findDentists: null
  },
  searchResult: {}
}
