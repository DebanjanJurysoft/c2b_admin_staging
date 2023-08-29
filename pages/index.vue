<template>
    <div class="row ">
        <div class="sidebar">
            <div class="logo">
                <Logo />
            </div>
            <div class="nav-items-container">
                <div class="nav-items" :class="nav.id == selectedMenu.id ? 'nav-items-active' : ''" v-for="(nav, ind) in menues" :key="ind" @click.prevent="setNewActive(ind)">
                    <img :src="`${nav.id == selectedMenu.id ? nav.active_img : nav.normal_img}`" alt="image">
                    <span>{{ nav.text }}</span>
                </div>
            </div>
            <span class="nav-items nav-items-active" style="margin-top: 16px;">
                <span>logout <i class="fa fa-sign-out" style="margin-left: 16px;"></i></span> 
            </span>
        </div>
    </div>
</template>

<script>
export default {
    data() {
        return {
            selectedMenu: {
                id: 1,
                text: 'home',
                normal_img: '/icons/home-black.svg',
                active_img: '/icons/home-white.svg'
            },
            menues: [
                {
                    id: 1,
                    text: 'home',
                    normal_img: '/icons/home-black.svg',
                    active_img: '/icons/home-white.svg'
                },
                {
                    id: 2,
                    text: 'vendors',
                    normal_img: '/icons/vendor-black.svg',
                    active_img: '/icons/vendor-white.svg'
                },
                {
                    id: 3,
                    text: 'products',
                    normal_img: '/icons/product-black.svg',
                    active_img: '/icons/product-white.svg'
                },
                {
                    id: 4,
                    text: 'orders',
                    normal_img: '/icons/order-black.svg',
                    active_img: '/icons/order-white.svg'
                },
                {
                    id: 5,
                    text: 'acount',
                    normal_img: '/icons/profile-black.svg',
                    active_img: '/icons/profile-white.svg'
                },
            ]
        }
    },
    methods: {
        setNewActive(ind) {
            this.selectedMenu = this.menues[ind]
        }
    }
}
</script>

