import Vue from 'vue'
import App from './components/App.vue'
import router from './router'
import store from './store'

import { mapState, mapActions } from 'vuex'
import { ACTION_TYPES } from './util/constants'
import ODLLUser from './blockchain/odll/ODLLUser'
import Search from './blockchain/search/Search'
import monitorWeb3 from './util/web3/monitorWeb3'

Vue.config.devtools = true
Vue.config.productionTip = false

/* eslint-disable no-new */

new Vue({
  el: '#app',
  router,
  store,
  template: '<App :is-d-app-ready="isDAppReady" :current-view="currentView" :is-valid-user-but="isValidUserBut" />',
  components: { App },
  beforeCreate: function () {
    this.$store.dispatch(ACTION_TYPES.REGISTER_WEB3_INSTANCE)
    .then((result) => {
      let state = result.state
      monitorWeb3(state)
      this.$store.dispatch(ACTION_TYPES.UPDATE_USER_BLOCKCHAIN_STATUS)
      .then(() => {
        ODLLUser.getUserDataFromTheBlockchain(state)
        .then((userObject) => {
          this.$store.dispatch(ACTION_TYPES.UPDATE_USER_STATE, {
            userObject
          })
          .then(() => {
            if (!(this.isDAppReady)) {
              this.forcedIsValidUserBut = '0'
              this.$store.dispatch(ACTION_TYPES.UPDATE_DAPP_READINESS, true)
            }
          })
          .catch(() => {
            console.log('Unable to UPDATE_USER_STATE')
            if (!(this.isDAppReady)) {
              this.$store.dispatch(ACTION_TYPES.UPDATE_DAPP_READINESS, true)
            }
          })
        })
        .catch((result = {}) => {
          console.error(result, 'Unable to getUserDataFromTheBlockchain')
          if (result.isValid) {
            this.$store.dispatch(ACTION_TYPES.INITIALISE_IS_VALID_USER_BUT, result.warningMessage)
            .then(() => {
              if (!(this.isDAppReady)) {
                this.$store.dispatch(ACTION_TYPES.UPDATE_DAPP_READINESS, true)
              }
            })
            .catch(() => {
              console.log('Unable to INITIALISE_IS_VALID_USER_BUT')
              if (!(this.isDAppReady)) {
                this.$store.dispatch(ACTION_TYPES.UPDATE_DAPP_READINESS, true)
              }
            })
          } else {
            if (!(this.isDAppReady)) {
              this.$store.dispatch(ACTION_TYPES.UPDATE_DAPP_READINESS, true)
            }
          }
        })
      })
      .catch((result = {}) => {
        console.error('Unable to UPDATE_USER_BLOCKCHAIN_STATUS')
        this.$store.dispatch(ACTION_TYPES.INITIALISE_IS_VALID_USER_BUT, result.warningMessage)
        .then(() => {
          if (!(this.isDAppReady)) {
            this.$store.dispatch(ACTION_TYPES.UPDATE_DAPP_READINESS, true)
          }
        })
        .catch(() => {
          if (!(this.isDAppReady)) {
            this.$store.dispatch(ACTION_TYPES.UPDATE_DAPP_READINESS, true)
          }
        })
      })
    })
    .catch((result = {}) => {
      let state = result.state
      this.forcedIsValidUserBut = '0'
      monitorWeb3(state)
      if (!(this.isDAppReady)) {
        this.$store.dispatch(ACTION_TYPES.UPDATE_DAPP_READINESS, true)
      }

      console.error(result, 'Unable to REGISTER_WEB3_INSTANCE')
    })
  },
  computed: {
    ...mapState({
      hasInjectedWeb3: state => state.web3.isInjected,
      hasWeb3InjectedBrowser: state => state.user.hasWeb3InjectedBrowser,
      isConnectedToODLLNetwork: state => state.user.isConnectedToODLLNetwork,
      hasCoinbase: state => state.user.hasCoinbase,
      networkId: state => state.web3.networkId,
      coinbase: state => state.web3.coinbase,
      currentRoute: state => state.currentRoute,
      currentView: state => state.currentView,
      user: state => state.user,
      isDAppReady: state => state.isDAppReady,
      isValidUserBut: state => state.isValidUserBut,
      originalIsValidUserBut: state => state.originalIsValidUserBut,
      gravatarURL: state => state.gravatarURL,
      avatarCanvas: state => state.avatarCanvas
    })
  },
  created: function () {
    this[ACTION_TYPES.CHANGE_CURRENT_ROUTE_TO](this.$route)
    this[ACTION_TYPES.SET_CURRENT_VIEW](this.$route)
  },
  methods: {
    ...mapActions([
      ACTION_TYPES.CHANGE_CURRENT_ROUTE_TO,
      ACTION_TYPES.UPDATE_USER_GRAVATAR,
      ACTION_TYPES.SET_IS_VALID_USER_BUT,
      ACTION_TYPES.RESET_IS_VALID_USER_BUT,
      ACTION_TYPES.SET_CURRENT_VIEW,
      ACTION_TYPES.UPDATE_USER_STATE,
      ACTION_TYPES.SAVE_SEARCH_RESULT
    ]),
    callUpdateUserGravatar (payload = null) {
      this[ACTION_TYPES.UPDATE_USER_GRAVATAR](payload)
    },
    callToWriteUser (payload = null) {
      ODLLUser.writeUser(this.$store.state, payload)
      .then((userData) => {
        this[ACTION_TYPES.UPDATE_USER_STATE]({
          isRaw: true,
          userObject: payload.vueUserObject
        })
        .then(() => {
          if (payload.callback) payload.callback(userData)
        })
      })
      .catch((err) => {
        if (payload.callback) payload.callback()
        console.error(err, 'Unable to write user data')
      })
    },
    callSetIsValidUserBut (newValue) {
      this[ACTION_TYPES.SET_IS_VALID_USER_BUT](newValue)
    },
    callResetIsValidUserBut () {
      this[ACTION_TYPES.RESET_IS_VALID_USER_BUT]()
    },
    callToFetchDataObjects (payload) {
      const fetchQuery = payload.fetchQuery
      const blockchainParams = Object.assign({}, fetchQuery)
      blockchainParams.seed = Math.ceil(blockchainParams.seed * 113)
      Search.fetchDataObjects(this.$store.state, blockchainParams)
      .then((fetchResult) => {
        this[ACTION_TYPES.SAVE_SEARCH_RESULT]({
          type: fetchQuery.type,
          seed: fetchQuery.seed,
          offset: fetchQuery.offset,
          results: fetchResult.results,
          totalNumberAvailable: fetchResult.totalNumberAvailable,
          callback: payload.callback
        })
        .catch((error) => {
          console.error(error)
        })
      })
      .catch((err) => {
        if (payload.callback) payload.callback()
        console.error(err, `Unable to fetch data for: ${fetchQuery.type}`)
      })
    },
    callToAddOfficialToODLL (payload = null) {
      const blockchainParams = Object.assign({}, payload)
      delete blockchainParams.callback
      ODLLUser.addOfficialToODLL(this.$store.state, blockchainParams)
      .then((userData) => {
        if (payload.callback) payload.callback(userData)
      })
      .catch((err) => {
        if (payload.callback) payload.callback(false)
        console.error(err, 'Unable to add official to the blockchain')
      })
    }
  },
  watch: {
    hasInjectedWeb3 (web3ConnectionValue) {
      console.log('hasInjectedWeb3: ', web3ConnectionValue)
    },
    networkId (networkId) {
      console.log('networkId: ', networkId)
    },
    coinbase (coinbase) {
      console.log('coinbase: ', coinbase)
    },
    isDAppReady (isDAppReady) {
      console.log('isDAppReady: ', isDAppReady)
      this.callSetIsValidUserBut(this.$route.query.isValidUserBut || this.forcedIsValidUserBut)
    },
    $route (newRoute) {
      this[ACTION_TYPES.CHANGE_CURRENT_ROUTE_TO](newRoute)
      this[ACTION_TYPES.SET_CURRENT_VIEW](newRoute)
      const isValidUserBut = this.$route.query.isValidUserBut
      if (isValidUserBut) {
        this.callSetIsValidUserBut(isValidUserBut)
      } else {
        this.callResetIsValidUserBut()
      }
    }
  }
})
