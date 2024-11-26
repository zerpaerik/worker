class ApiWebServer {
  static const dev_server_name = 'https://emplooy.com';
  static const prod_server_name = 'https://emplooy.com';
  static const server_name = dev_server_name;
  static const API_REGISTER_USER = server_name + '/api/v-1/user/register';
  static const API_REGISTER_W4 =
      server_name + '/api/v-1/w_forms/create_w4_form';
  static const API_AUTH_LOGIN = server_name + '/api/v-2/auth/login';
  static const API_AUTH_LOGOUT = server_name + '/api/v-1/auth/logout';
  static const API_UPDATE_USER = server_name + '/api/v-1/user/profile_update';
  static const API_GET_USER = server_name + '/api/v-1/user/get_user_profile';
  static const API_GET_VERIFY_EMAIL =
      server_name + '/api/v-1/auth/verify_email';
  static const API_GET_VERIFY_CODE = server_name + '/api/v-1/auth/verify_code';
  static const API_AUTH_CHANGE_PASSWORD =
      server_name + '/api/v-1/auth/change_password';
  static const API_UPDATE_USER_OPTIONAL =
      server_name + '/api/user/optional_profile_update';
  static const API_GET_CERTIFICATION_TYPE =
      server_name + '/api/v-1/certification/type/';
  static const API_CERTIFICATION = server_name + '/api/v-1/certification/';
  static const API_GET_DETAILL_OFFERJOB =
      server_name + '/api/v-1/contract/joboffer/';
  static const API_PATCH_APPLY_OFFER =
      server_name + '/api/v-1/contract/joboffer/apply/';
  static const API_PATCH_VERIFIED_NOTIF = server_name + '/api/v-1/notification';
  static const API_CREATE_WORKDAY = server_name + '/api/v-1/workday/create';
  static const API_UTC_HOUR_NEW_CHAT =
      server_name + '/api/v-1/user/timezone-now';
}
