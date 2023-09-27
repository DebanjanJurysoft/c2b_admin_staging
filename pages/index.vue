<template>
    <div class="row">
        <Sidebar @setNewActive="setNewActive" :selectedMenu="selectedMenu" />
        <div class="pages-container">
            <Topbar @updateNewActive="updateNewActive" :selectedMenu="selectedMenu"/>
            <Dashboard v-if="selectedMenu.name == 'home'"/>
            <Vendors :searchText="selectedMenu.searchText" v-if="selectedMenu.name == 'vendors'" />
            <Products :searchText="selectedMenu.searchText" v-if="selectedMenu.name == 'products'" />
            <Orders :searchText="selectedMenu.searchText" v-if="selectedMenu.name == 'orders'"/>
            <Payments :searchText="selectedMenu.searchText" v-if="selectedMenu.name == 'payments'"/>
            <Customers :searchText="selectedMenu.searchText" v-if="selectedMenu.name == 'customers'"/>
        </div>
    </div>
</template>

<script>
import Customers from '../components/customers.vue';
import Dashboard from '../components/dashboard.vue';
import Orders from '../components/orders.vue';
import Payments from '../components/payments.vue';
import Products from '../components/products.vue';
import Sidebar from '../components/sidebar.vue';
import Topbar from '../components/topbar.vue';
import Vendors from '../components/vendors.vue';

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
    components: { Sidebar, Topbar, Dashboard, Vendors, Products, Orders, Payments, Customers }
}
</script>

