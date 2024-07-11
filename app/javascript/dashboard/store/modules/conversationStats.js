import Vue from 'vue';
import types from '../mutation-types';
import ConversationApi from '../../api/inbox/conversation';

const state = {
  meta: {
    mineCount: 0,
    unAssignedCount: 0,
    allCount: 0,
    conversationCount: 0,
    mentionedCount: 0,
    unattendedCount: 0,
  }
};

export const getters = {
  getStats: $state => $state.meta,
};

export const actions = {
  get: async ({ commit }, params) => {
    try {
      const response = await ConversationApi.meta(params);
      const {
        data: { meta },
      } = response;
      commit(types.SET_CONV_TAB_META, meta);
    } catch (error) {
      // Ignore error
    }
  },
  set({ commit }, meta) {
    commit(types.SET_CONV_TAB_META, meta);
  },
};

export const mutations = {
  [types.SET_CONV_TAB_META]($state, meta) {
    $state.meta = {
      mineCount: meta.mine_count,
      unAssignedCount: meta.unassigned_count,
      allCount: meta.all_count,
      conversationCount: meta.conversation_count,
      mentionedCount: meta.mentioned_count,
      unattendedCount: meta.unattended_count,
    };
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
