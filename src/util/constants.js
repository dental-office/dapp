export const NETWORKS = {
  '1': 'Main Net',
  '2': 'Deprecated Morden test network',
  '3': 'Ropsten test network',
  '4': 'Rinkeby test network',
  '42': 'Kovan test network',
  '666': 'DanielNet test network',
  '4447': 'Truffle Develop Network',
  '5777': 'Ganache Blockchain'
}

export const APPROVED_BLOCKCHAIN_NETWORK_ID = '3'

export const MUTATION_TYPES = {
  CHANGE_CURRENT_ROUTE_TO: 'changeCurrentRouteTo',
  SET_CURRENT_VIEW: 'setCurrentView',
  REGISTER_WEB3_INSTANCE: 'registerWeb3Instance',
  UPDATE_USER_BLOCKCHAIN_STATUS: 'updateUserBlockchainStatus',
  UPDATE_USER_STATE: 'updateUserState',
  UPDATE_USER_GRAVATAR: 'updateUserGravatar',
  UPDATE_DAPP_READINESS: 'updateDAppReadiness',
  INITIALISE_IS_VALID_USER_BUT: 'initialiseIsValidUserBut',
  SET_IS_VALID_USER_BUT: 'setIsValidUserBut',
  RESET_IS_VALID_USER_BUT: 'resetIsValidUserBut',
  UPDATE_WEB3_PROPERTIES: 'updateWeb3Properties',
  SAVE_CURRENT_SEARCH_SEED: 'saveCurrentSearchSeed',
  CLEAR_SEARCH_RESULT: 'clearSearchResult',
  SAVE_SEARCH_RESULT: 'saveSearchResult',
  SAVE_TOTAL_NUMBER_AVAILABLE: 'saveTotalNumberAvailable'
}

export const ACTION_TYPES = MUTATION_TYPES

export const IDENTICON_COLORS = [
  {
    color: '#dadada',
    bgColor: '#838383',
    spotColor: '#9f9f9f'
  },
  {
    color: '#a87edf',
    bgColor: '#f0f0f0',
    spotColor: '#a87edf'
  },
  {
    color: '#acd888',
    bgColor: '#ffffff',
    spotColor: '#acd888'
  },
  {
    color: '#89e18a',
    bgColor: '#f0f0f0',
    spotColor: '#89e18a'
  },
  {
    color: '#7e4581',
    bgColor: '#f0f0f0',
    spotColor: '#7e4581'
  },
  {
    color: '#2d4fff',
    bgColor: '#e0e0e0',
    spotColor: '#2d4fff'
  },
  {
    color: '#38aad4',
    bgColor: '#ffffff',
    spotColor: '#38aad4'
  },
  {
    color: '#77c5d4',
    bgColor: '#f0f0f0',
    spotColor: '#77c5d4'
  },
  {
    color: '#6fd8b5',
    bgColor: '#f0f0f0',
    spotColor: '#6fd8b5'
  },
  {
    color: '#6a57cf',
    bgColor: '#eeeeee',
    spotColor: '#6a57cf'
  },
  {
    color: '#fc5e03',
    bgColor: '#eeeeee',
    spotColor: '#fc5e03'
  },
  {
    color: '#89a9da',
    bgColor: '#f0f0f0',
    spotColor: '#89a9da'
  },
  {
    color: '#d96e9c',
    bgColor: '#eeeeee',
    spotColor: '#d96e9c'
  },
  {
    color: '#b69bde',
    bgColor: '#f0f0f0',
    spotColor: '#b69bde'
  },
  {
    color: '#e279ea',
    bgColor: '#e0e0e0',
    spotColor: '#e279ea'
  },
  {
    color: '#d4bc4e',
    bgColor: '#f0f0f0',
    spotColor: '#d4bc4e'
  }
]

const corsAnywhere = 'https://cors-anywhere.herokuapp.com/'
export const EXCHANGE_RATE_API = `${corsAnywhere}https://api.coinmarketcap.com/v1/ticker/ethereum`
