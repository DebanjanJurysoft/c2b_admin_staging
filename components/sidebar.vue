<template>
    <div class="sidebar-container">
        <div class="sidebar">
            <div class="logo">
                <Logo />
            </div>
            <div class="nav-items-container">
                <div class="nav-items" :class="nav.id == selectedMenu.id ? 'nav-items-active' : ''" v-for="(nav, ind) in menues" :key="ind" @click.prevent="setActive(ind)">
                    <img :src="`${nav.id == selectedMenu.id ? nav.active_img : nav.normal_img}`" alt="image">
                    <span>{{ nav.name }}</span>
                </div>
            </div>
        </div>
        <span class="logout-button" @click.prevent="logout">
            <span>logout <i class="fa fa-sign-out"></i></span> 
        </span>
    </div>
</template>

<script>
export default {
    data() {
        return {
            menues: [
                {
                    id: 1,
                    name: 'home',
                    normal_img: '/icons/home-black.svg',
                    active_img: '/icons/home-white.svg'
                },
                {
                    id: 2,
                    name: 'vendors',
                    normal_img: '/icons/vendor-black.svg',
                    active_img: '/icons/vendor-white.svg'
                },
                {
                    id: 3,
                    name: 'products',
                    normal_img: '/icons/product-black.svg',
                    active_img: '/icons/product-white.svg'
                },
                {
                    id: 4,
                    name: 'orders',
                    normal_img: '/icons/order-black.svg',
                    active_img: '/icons/order-white.svg'
                },
                {
                    id: 5,
                    name: 'Payments',
                    normal_img: '/icons/order-black.svg',
                    active_img: '/icons/order-white.svg'
                },
                {
                    id: 6,
                    name: 'account',
                    normal_img: '/icons/profile-black.svg',
                    active_img: '/icons/profile-white.svg'
                },
            ]
        }
     },
    props: [ 'selectedMenu' ],
    methods: {
        setActive(ind) {
            const selectedMenu = this.menues[ind]
            this.$emit('setNewActive', selectedMenu)
        },
        async logout() {
            await this.$auth.logout()
            this.$router.push('/login')
        }
    }
}
</script>
