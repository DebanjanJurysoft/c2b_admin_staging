<template>
    <!-- <div class="row" @mousemove="isUsing"> -->
    <div class="row" >
    <!-- <div class="row"> -->
        <Sidebar @setNewActive="setNewActive" :selectedMenu="selectedMenu" ref="childComponentRef"  />
        <div class="pages-container">
            <Topbar @updateNewActive="updateNewActive" :selectedMenu="selectedMenu"/>
            <!-- <Vendor_form v-if="selectedMenu.name == 'home'"/> -->
            <Dashboard v-if="selectedMenu.name == 'home'"/>
            <!-- <Category v-if="selectedMenu.name == 'home'"/> -->
            <PrivacyPolicy :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'privacy policy'" />
            <Attributes :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'attributes'" />
            <Plans :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'plans'" />
            <Vendors :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'vendors'" />
            <Coupons :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'coupons'" />
            <Products :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'products'" />
            <Orders :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'orders'"/>
            <Payments :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'payments'"/>
            <Customers :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'customers'"/>
            <Banners :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'banners'"/>
            <Addons :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'addons'"/>
            <Category :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'sub-category'"/>
            <Stores :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'stores'"/>
            <Malls :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'malls'"/>
            <Notifications :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'notifications'"/>
            <Reports :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'reports'"/>
            <Admins :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'admins'"/>
            <AdminPermissions :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'admin permissions'"/>
            <Services :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'services'"/>
            <ServiceProviders :searchText="selectedMenu.searchText" @reloadDashboard="reloadDashboard" v-if="selectedMenu.name == 'service_provider'"/>
        </div>
    </div>
</template>

<script>
import Banners from '../components/banners.vue';
import Plans from '../components/plans.vue';
import Coupons from '../components/coupons.vue';
import Category from '../components/category.vue';
import Customers from '../components/customers.vue';
import Dashboard from '../components/dashboard.vue';
import Orders from '../components/orders.vue';
import Reports from '../components/reports.vue';
import Payments from '../components/payments.vue';
import Products from '../components/products.vue';
import Sidebar from '../components/sidebar.vue';
import Topbar from '../components/topbar.vue';
import Vendor_form from '../components/vendor_form.vue';
import Vendors from '../components/vendors.vue';
import Addons from '../components/addons.vue';
import Stores from '../components/stores.vue';
import Malls from '../components/malls.vue';
import PrivacyPolicy from '../components/privacy_policy.vue';
import Notifications from '../components/notifications.vue';
import Attributes from '../components/categoryAttributes.vue';
import Admins from '../components/admins.vue';
import AdminPermissions from '../components/admin_permissions.vue';
import Services from '../components/services.vue';
import ServiceProviders from '../components/serviceProviders.vue';

export default {
    data() {
        return {
            not_active_timer: null,
            not_use_max_time: 900000,
            tabIsActive: null,
            selectedMenu: {
                id: 1,
                name: 'home',
                text: 'home',
                noSearch: true,
                normal_img: '/icons/home-black.svg',
                active_img: '/icons/home-white.svg'
            },
            intervalTimeOut: null,
            localStorageServer: null
        };
    },
    async mounted() {

        const token = localStorage.getItem('token')
        if (!token) {
            console.log(token);
            // await this.$auth.logout()
            this.$router.push('/login')
        } else {
            this.$axios.setHeader('Authorization', token)
        }

        // socket.io start
        // await this.$socket.connect()
        // await this.$socket.on('server-connected', async (message) => {
        //     this.$toast.show(message.message, {
        //         duration: 700,
        //         position: 'top-right',
        //         keepOnHover: true,
        //         type: 'success'
        //     })
        //     if (localStorage.getItem('socket_id')) {
        //         await this.$axios.get(`/remove-socket/${localStorage.getItem('socket_id')}`)
        //         localStorage.setItem('socket_id', message.id)
        //     } else {
        //         localStorage.setItem('socket_id', message.id)
        //     }
        //     // Update your component state or perform other actions
        // });
        // await this.$socket.on('server-message', async (message) => {
        //     this.$toast.show(message, {
        //         duration: 1500,
        //         position: 'top-right',
        //         keepOnHover: true,
        //         type: 'success'
        //     })
        // });
        // socket.io end

        
        localStorage.removeItem('navData')
        this.changeTab()
        // this.isUsing()
        // if (typeof document.hidden !== "undefined") {
        //     document.addEventListener("visibilitychange", this.handleVisibilityChange);
        // } else {
        //     console.log("Page Visibility API is not supported in this browser");
        // }
    },
    beforeDestroy() {
        // Disconnect the Socket.IO connection when the page is destroyed
        // this.$socket.disconnect();
    },
    methods: {
        reloadDashboard() {
            this.$refs.childComponentRef.reloadSidebar();
        },
        changeTab() {
            this.intervalTimeOut = setInterval(() => {
                this.localStorageServer = localStorage.getItem('navData')
                if (typeof this.localStorageServer === 'string') {
                    this.localStorageServer = JSON.parse(this.localStorageServer)
                    this.setNewActive(this.localStorageServer.nav)
                    clearInterval(this.intervalTimeOut)
                }
            }, 100);
        },
        // handleVisibilityChange() {
        //     this.tabIsActive = !document.hidden;
        //     if (!this.tabIsActive) {
        //         this.isUsing()
        //     }
        // }, 
        async logout() {
            localStorage.removeItem('token')
            // localStorage.removeItem('refreshToken')
            this.$router.push('/login')
        },
        // async isUsing() { 
        //     clearTimeout(this.not_active_timer)
        //     this.not_active_timer = setTimeout(async () => {
        //         await this.logout()
        //     }, this.ad);
        // },
        updateNewActive(selected) {
            this.selectedMenu = selected;
        },
        setNewActive(selected) {
            if (this.selectedMenu.name == 'home') {
                if (this.localStorageServer && !this.localStorageServer.inner_nav) {
                    localStorage.removeItem('navData')
                }
                this.changeTab()
            }
            this.selectedMenu = selected;
        }
    },
    components: { Sidebar, Topbar, Dashboard, Vendors, Products, Orders, Payments, Customers, Vendor_form, Category, Banners, Addons, Stores, Coupons, Plans, Malls, PrivacyPolicy, Notifications, Reports, Attributes, Admins, AdminPermissions, Services, ServiceProviders }
}
</script>

