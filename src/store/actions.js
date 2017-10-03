import { ACTION_TYPES, MUTATION_TYPES } from '../util/constants'
import getWeb3 from '../util/web3/getWeb3'
import monitorWeb3 from '../util/web3/monitorWeb3'

export default {
  [ACTION_TYPES.REGISTER_WEB3_INSTANCE] ({ commit, dispatch }) {
    return new Promise(function (resolve, reject) {
      // Try to initialize web3
      getWeb3
      .then((result) => {
        commit(MUTATION_TYPES.REGISTER_WEB3_INSTANCE, {
          result,
          callback: (state) => {
            monitorWeb3(state)
            resolve()
          }
        })
      })
      .catch((e) => {
        const result = e.result
        commit(MUTATION_TYPES.REGISTER_WEB3_INSTANCE, {
          result: {
            web3: (result && result.hasInjectedWeb3 ? () => result.web3 : null),
            hasInjectedWeb3: (result && result.hasInjectedWeb3 ? result.hasInjectedWeb3 : false),
            web3Error: e.err
          },
          callback: (state) => {
            monitorWeb3(state)
            resolve(result)
          }
        })
      })
    })
  },
  [ACTION_TYPES.UPDATE_USER_BLOCKCHAIN_STATUS] ({ commit }) {
    commit(MUTATION_TYPES.UPDATE_USER_BLOCKCHAIN_STATUS)
  },
  [ACTION_TYPES.CHANGE_CURRENT_ROUTE_TO] ({ commit }, newRoute) {
    commit(MUTATION_TYPES.CHANGE_CURRENT_ROUTE_TO, newRoute)
  },
  [ACTION_TYPES.UPDATE_USER_AVATAR_CANVAS] ({ commit }, payload) {
    commit(MUTATION_TYPES.UPDATE_USER_AVATAR_CANVAS, payload)
  },
  [ACTION_TYPES.UPDATE_DAPP_READINESS] ({ commit }, isReady) {
    commit(MUTATION_TYPES.UPDATE_DAPP_READINESS, isReady)
  }
}
