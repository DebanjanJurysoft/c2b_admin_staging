export default {
  devtools: { enabled: true },
  // Global page headers: https://go.nuxtjs.dev/config-head
  head: {
    title: 'Close2Buy',
    htmlAttrs: {
      lang: 'en'
    },
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { hid: 'description', name: 'description', content: '' },
      { name: 'format-detection', content: 'telephone=no' }
    ],
    link: [
      {
        rel: 'stylesheet',
        href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css',
      },
      { rel: 'icon', type: 'image/x-icon', href: '/images/small-logo.png' }
    ]
  },

  // Global CSS: https://go.nuxtjs.dev/config-css
  css: [
    '~/static/css/topbar.css',
    '~/static/css/dashboard.css',
    '~/static/css/style.css',
    '~/static/css/sidebar.css',
    '~/static/css/loginpage.css',
    '~/static/css/vendors.css',
    '~/static/css/table.css',
    '~/static/css/sidebarComponent.css',
    '~/static/css/products.css',
    '~/static/css/orders.css',
    '~/static/css/payments.css',
    '~/static/css/customer.css',
    '~/static/css/vendor_form.css',
    '~/static/css/category.css',
    '~/static/css/banner.css',
    '~/static/css/addons.css',
  ],

  // Plugins to run before rendering page: https://go.nuxtjs.dev/config-plugins
  plugins: [
  ],

  // Auto import components: https://go.nuxtjs.dev/config-components
  components: true,

  // Modules for dev and build (recommended): https://go.nuxtjs.dev/config-modules
  buildModules: [
  ],

  // Modules: https://go.nuxtjs.dev/config-modules
  modules: [
    // https://go.nuxtjs.dev/bootstrap
    'bootstrap-vue/nuxt',
    // https://go.nuxtjs.dev/axios
    '@nuxtjs/axios',
    '@nuxtjs/auth',
    '@nuxtjs/toast',
    'nuxt-vue-select',
  ],

  auth: {
    strategies: {
      local: {
        endpoints: {
          login: {
            url: '/login-admin',
            method: 'post',
            propertyName: 'token'
          },
          logout: {
            url: '/logout-user',
            method: 'post'
          },
          user: {
            url: '/get-user',
            method: 'get',
            propertyName: 'user'
          }
        },
        tokenType: ''
      }
    }
  },
  // Axios module configuration: https://go.nuxtjs.dev/config-axios
  axios: {
    // Workaround to avoid enforcing hard-coded localhost:3000: https://github.com/nuxt-community/axios-module/issues/308
    baseURL: 'https://close2buy-dev.jurysoftprojects.com/api',
    // baseURL: 'http://localhost:3031/api',
  },

  // Build Configuration: https://go.nuxtjs.dev/config-build
  build: {
  }
}
