<template>
    <div class="sidebar-container">
        <div class="sidebar mb-3">
            <div class="logo">
                <Logo />
            </div>
            <div class="nav-items-container">
                <template v-for="(nav, ind) in menues" >
                    <div class="nav-items d-flex justify-content-between" :class="nav.id == selectedMenu.id ? 'nav-items-active' : nav.collapsable && !nav.active && nav.options.includes(selectedMenu) ? 'nav-items-active' : ''" :key="ind" @click.prevent="setActive(ind)">
                        <div>
                            <img :src="`${nav.id == selectedMenu.id ? nav.active_img : nav.collapsable && !nav.active && nav.options.includes(selectedMenu) ? nav.active_img : nav.normal_img}`" alt="image">
                            <span>{{ nav.name }}</span>
                        </div>
                        <i v-if="nav.collapsable && !nav.active" class="fa fa-angle-down"></i>
                        <i v-if="nav.collapsable && nav.active" class="fa fa-angle-up"></i>
                    </div>
                    <template v-if="nav.active" v-for="(nav_sub, nav_sub_ind) in nav.options">
                        <div class="pl-5 nav-items d-flex justify-content-between" :class="nav_sub.id == selectedMenu.id ? 'nav-items-active' : ''" :key="`${ind}X${nav_sub_ind}`" @click.prevent="setActive(ind, nav_sub_ind)">
                        <div>
                            <img :src="`${nav_sub.id == selectedMenu.id ? nav_sub.active_img : nav_sub.normal_img}`" alt="image">
                            <span>{{ nav_sub.name }}</span>
                        </div>
                    </div>
                    </template>
                </template>
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
                    id: 16,
                    name: 'stores',
                    normal_img: '/icons/vendor-black.svg',
                    active_img: '/icons/vendor-white.svg'
                },
                {
                    id: 4,
                    name: 'inventory',
                    normal_img: '/icons/Inventory-black.svg',
                    active_img: '/icons/Inventory-white.svg',
                    collapsable: true,
                    active: false,
                    options: [
                        {
                            id: 9,
                            name: 'products',
                            normal_img: '/icons/product-black.svg',
                            active_img: '/icons/product-white.svg'
                        },
                        {
                            id: 10,
                            name: 'banners',
                            normal_img: '/icons/banner-black.svg',
                            active_img: '/icons/banner-white.svg'
                        },
                        {
                            id: 11,
                            name: 'addons',
                            normal_img: '/icons/addon-black.svg',
                            active_img: '/icons/addon-white.svg'
                        },
                        // {
                        //     id: 12,
                        //     name: 'category',
                        //     normal_img: '/icons/category-black.svg',
                        //     active_img: '/icons/category-white.svg'
                        // },
                        {
                            id: 13,
                            name: 'sub-category',
                            normal_img: '/icons/category-black.svg',
                            active_img: '/icons/category-white.svg'
                        },
                    ]
                },
                {
                    id: 5,
                    name: 'orders',
                    normal_img: '/icons/order-black.svg',
                    active_img: '/icons/order-white.svg'
                },
                {
                    id: 6,
                    name: 'payments',
                    normal_img: '/icons/payment-black.svg',
                    active_img: '/icons/payment-white.svg'
                },
                {
                    id: 7,
                    name: 'customers',
                    normal_img: '/icons/customer-black.svg',
                    active_img: '/icons/customer-white.svg'
                },
                {
                    id: 8,
                    name: 'account',
                    normal_img: '/icons/profile-black.svg',
                    active_img: '/icons/profile-white.svg',
                    collapsable: true,
                    active: false,
                    options: [
                        {
                            id: 14,
                            name: 'FAQ',
                            normal_img: '/icons/product-black.svg',
                            active_img: '/icons/product-white.svg'
                        },
                        {
                            id: 15,
                            name: 'feedback',
                            normal_img: '/icons/product-black.svg',
                            active_img: '/icons/product-white.svg'
                        },
                    ]
                },
            ],
            main_index: 0,
            sub_index: null
        }
     },
    props: [ 'selectedMenu' ],
    methods: {
        setActive(ind, sub_ind = null) {
            this.main_index = ind
            this.sub_index = sub_ind
            if (this.sub_index == null && this.sub_index != 0) {
                let selectedMenu = this.menues[this.main_index]
                if (this.menues[this.main_index].collapsable) {
                    this.collaps(this.main_index)
                    selectedMenu = this.menues[this.main_index].options[this.sub_index == null ? 0 : this.sub_index]
                }
                this.$emit('setNewActive', selectedMenu)
            }
            if (this.sub_index != null) {
                const selectedMenu = this.menues[this.main_index].options[this.sub_index]
                this.$emit('setNewActive', selectedMenu)
                // console.log(selectedMenu);
            }
        },
        async logout() {
            await this.$auth.logout()
            this.$router.push('/login')
        },
        collaps(ind) {
            this.menues[ind].active = !this.menues[ind].active
        }
    }
}
</script>
