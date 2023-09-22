<template>
    <div class="row">
        <Sidebar @setNewActive="setNewActive" :selectedMenu="selectedMenu" />
        <div class="pages-container">
            <Topbar @updateNewActive="updateNewActive" :selectedMenu="selectedMenu"/>
            <Dashboard v-if="selectedMenu.name == 'home'"/>
            <Vendors :searchText="selectedMenu.searchText" v-if="selectedMenu.name == 'vendors'" />
            <Products :searchText="selectedMenu.searchText" v-if="selectedMenu.name == 'products'" />
        </div>
    </div>
</template>

<script>
import Dashboard from '../components/dashboard.vue';
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
                id: 2,
                name: 'vendors',
                searchText: null,
                normal_img: '/icons/vendor-black.svg',
                active_img: '/icons/vendor-white.svg'
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
    components: { Sidebar, Topbar, Dashboard, Vendors, Products }
}
</script>

