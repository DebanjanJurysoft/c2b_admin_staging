<template>
    <div class="row">
        <Sidebar @setNewActive="setNewActive" :selectedMenu="selectedMenu" />
        <div class="pages-container">
            <Topbar  :selectedMenu="selectedMenu"/>
            <Dashboard v-if="selectedMenu.name == 'home'"/>
            <Vendors v-if="selectedMenu.name == 'vendors'" />
        </div>
    </div>
</template>

<script>
import Dashboard from '../components/dashboard.vue';
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
        setNewActive(selected) {
            this.selectedMenu = selected;
        }
    },
    components: { Sidebar, Topbar, Dashboard, Vendors }
}
</script>

