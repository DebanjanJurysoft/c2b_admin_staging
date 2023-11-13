<template>
    <div class="row" @mousemove="isUsing">
    <!-- <div class="row"> -->
        <Sidebar @setNewActive="setNewActive" :selectedMenu="selectedMenu" />
        <div class="pages-container">
            <Topbar @updateNewActive="updateNewActive" :selectedMenu="selectedMenu"/>
            <!-- <Vendor_form v-if="selectedMenu.name == 'home'"/> -->
            <Dashboard v-if="selectedMenu.name == 'home'"/>
            <!-- <Category v-if="selectedMenu.name == 'home'"/> -->
            <Vendors :searchText="selectedMenu.searchText" v-if="selectedMenu.name == 'vendors'" />
            <Products :searchText="selectedMenu.searchText" v-if="selectedMenu.name == 'products'" />
            <Orders :searchText="selectedMenu.searchText" v-if="selectedMenu.name == 'orders'"/>
            <Payments :searchText="selectedMenu.searchText" v-if="selectedMenu.name == 'payments'"/>
            <Customers :searchText="selectedMenu.searchText" v-if="selectedMenu.name == 'customers'"/>
            <Banners :searchText="selectedMenu.searchText" v-if="selectedMenu.name == 'banners'"/>
            <Addons :searchText="selectedMenu.searchText" v-if="selectedMenu.name == 'addons'"/>
            <Category :searchText="selectedMenu.searchText" v-if="selectedMenu.name == 'sub-category'"/>
            <Stores :searchText="selectedMenu.searchText" v-if="selectedMenu.name == 'stores'"/>
        </div>
    </div>
</template>

<script>
import Banners from '../components/banners.vue';
import Category from '../components/category.vue';
import Customers from '../components/customers.vue';
import Dashboard from '../components/dashboard.vue';
import Orders from '../components/orders.vue';
import Payments from '../components/payments.vue';
import Products from '../components/products.vue';
import Sidebar from '../components/sidebar.vue';
import Topbar from '../components/topbar.vue';
import Vendor_form from '../components/vendor_form.vue';
import Vendors from '../components/vendors.vue';
import Addons from '../components/addons.vue';
import Stores from '../components/stores.vue';

export default {
    async beforeCreate() {
        if (!this.$auth.loggedIn) {
            // await this.$auth.logout()
            this.$router.push('/login')
        }
    },
    data() {
        return {
            not_active_timer: null,
            not_use_max_time: 900000,
            tabIsActive: null,
            selectedMenu: {
                id: 1,
                name: 'home',
                text: 'home',
                normal_img: '/icons/home-black.svg',
                active_img: '/icons/home-white.svg'
            },
            intervalTimeOut: null,
            localStorageServer: null
        };
    },
    mounted() {
        localStorage.removeItem('navData')
        this.changeTab()
        this.isUsing()
        if (typeof document.hidden !== "undefined") {
            document.addEventListener("visibilitychange", this.handleVisibilityChange);
        } else {
            console.log("Page Visibility API is not supported in this browser");
        }
    },
    methods: {
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
        handleVisibilityChange() {
            this.tabIsActive = !document.hidden;
            if (!this.tabIsActive) {
                this.isUsing()
            }
        }, 
        async logout() {
            await this.$auth.logout()
            this.$router.push('/login')
        },
        async isUsing() { 
            clearTimeout(this.not_active_timer)
            this.not_active_timer = setTimeout(async () => {
                await this.logout()
            }, this.not_use_max_time);
        },
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
    components: { Sidebar, Topbar, Dashboard, Vendors, Products, Orders, Payments, Customers, Vendor_form, Category, Banners, Addons, Stores }
}
</script>

