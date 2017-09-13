import { ACTION_TYPES, MUTATION_TYPES } from '../util/constants'
import getWeb3 from '../util/web3/getWeb3'

export default {
  [ACTION_TYPES.REGISTER_WEB3_INSTANCE] ({ commit, dispatch }) {
    return new Promise(function (resolve, reject) {
      // Try to initialize web3
      getWeb3
      .then((result) => {
        commit(MUTATION_TYPES.REGISTER_WEB3_INSTANCE, {
          result,
          callback: () => resolve()
        })
      })
      .catch((e) => {
        if (e.result) {
          const result = e.result
          commit(MUTATION_TYPES.REGISTER_WEB3_INSTANCE, {
            result: {
              web3: (result.hasInjectedWeb3 ? () => result.web3 : null),
              hasInjectedWeb3: (result.hasInjectedWeb3 ? result.hasInjectedWeb3 : false),
              web3Error: e.err
            },
            callback: () => resolve(result)
          })
        }
      })
    })
  },
  [ACTION_TYPES.UPDATE_USER_BLOCKCHAIN_STATUS] ({ commit }) {
    commit(MUTATION_TYPES.UPDATE_USER_BLOCKCHAIN_STATUS)
  },
  [ACTION_TYPES.CHANGE_CURRENT_ROUTE_TO] ({ commit }, newRoute) {
    commit(MUTATION_TYPES.CHANGE_CURRENT_ROUTE_TO, newRoute)
  }
}