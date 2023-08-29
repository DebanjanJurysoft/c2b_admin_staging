<template>
    <div class="row">
        <Sidebar @setNewActive="setNewActive" :selectedMenu="selectedMenu" />
        <div class="pages-container">
        </div>
    </div>
</template>

<script>
import Sidebar from '../components/sidebar.vue';

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
                text: 'home',
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
    components: { Sidebar }
}
</script>

