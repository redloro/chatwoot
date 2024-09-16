/* global axios */
import ApiClient from './ApiClient';

class CustomViewsAPI extends ApiClient {
  constructor() {
    super('custom_filters', { accountScoped: true });
  }

  getCustomViewsByFilterType(params = {}) {
    return axios.get(`${this.url}`, { params });
  }

  deleteCustomViews(id, type) {
    return axios.delete(`${this.url}/${id}?filter_type=${type}`);
  }
}

export default new CustomViewsAPI();
