<template>
    <div class="row">
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
    beforeCreate() {
        if (!this.$auth.loggedIn) {
            this.$router.push('/login')
        }
    },
    data() {
        return {
            selectedMenu: {
                id: 1,
                name: 'home',
                normal_img: '/icons/home-black.svg',
                active_img: '/icons/home-white.svg'
            },
        };
    },
    methods: { 
        updateNewActive(selected) {
            this.selectedMenu = selected;
        },
        setNewActive(selected) {
            this.selectedMenu = selected;
        }
    },
    components: { Sidebar, Topbar, Dashboard, Vendors, Products, Orders, Payments, Customers, Vendor_form, Category, Banners, Addons, Stores }
}
</script>

