<template>
    <div v-if="loader" class="sidebar-container loader">
        <Loader />
    </div>
    <div v-else class="sidebar-container">
        <div class="sidebar mb-3">
            <div class="logo">
                <Logo />
            </div>
            <div class="nav-items-container">
                <template v-for="(nav, ind) in menues" >
                    <div class="nav-items d-flex justify-content-between" :class="nav.id == selectedMenu.id ? 'nav-items-active' : nav.collapsable && !nav.active && nav.options.includes(selectedMenu) ? 'nav-items-active' : ''" :key="ind" @click.prevent="setActive(ind)">
                        <div>
                            <img :src="`${nav.id == selectedMenu.id ? nav.active_img : nav.collapsable && !nav.active && nav.options.includes(selectedMenu) ? nav.active_img : nav.normal_img}`" alt="image">
                            <span>{{ nav.text }}</span>
                        </div>
                        <i v-if="nav.collapsable && !nav.active" class="fa fa-angle-down"></i>
                        <i v-if="nav.collapsable && nav.active" class="fa fa-angle-up"></i>
                    </div>
                    <template v-if="nav.active" v-for="(nav_sub, nav_sub_ind) in nav.options">
                        <div class="pl-5 nav-items d-flex justify-content-between" :class="nav_sub.id == selectedMenu.id ? 'nav-items-active' : ''" :key="`${ind}X${nav_sub_ind}`" @click.prevent="setActive(ind, nav_sub_ind)">
                        <div>
                            <img :src="`${nav_sub.id == selectedMenu.id ? nav_sub.active_img : nav_sub.normal_img}`" alt="image">
                            <span>{{ nav_sub.text }}</span>
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
import Loader from './loader.vue'

export default {
    data() {
        return {
            loader: true,
            menues: [
                {
                    id: 1,
                    name: 'home',
                    text: 'home',
                    normal_img: '/icons/home-black.svg',
                    active_img: '/icons/home-white.svg'
                },
                {
                    id: 2,
                    name: 'vendors',
                    text: 'vendors',
                    normal_img: '/icons/vendor-black.svg',
                    active_img: '/icons/vendor-white.svg'
                },
                {
                    id: 16,
                    name: 'stores',
                    text: 'stores',
                    normal_img: '/icons/shop-black.svg',
                    active_img: '/icons/shop-white.svg'
                },
                {
                    id: 19,
                    name: 'malls',
                    text: 'malls',
                    normal_img: '/icons/malls-black.svg',
                    active_img: '/icons/malls-white.svg'
                },
                {
                    id: 4,
                    name: 'inventory',
                    text: 'inventory',
                    normal_img: '/icons/Inventory-black.svg',
                    active_img: '/icons/Inventory-white.svg',
                    collapsable: true,
                    active: false,
                    options: [
                        {
                            id: 9,
                            name: 'products',
                            text: 'products',
                            normal_img: '/icons/product-black.svg',
                            active_img: '/icons/product-white.svg'
                        },
                        {
                            id: 10,
                            name: 'banners',
                            text: 'banners',
                            normal_img: '/icons/banner-black.svg',
                            active_img: '/icons/banner-white.svg'
                        },
                        {
                            id: 11,
                            name: 'addons',
                            text: 'addons',
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
                            text: 'sub-category',
                            normal_img: '/icons/category-black.svg',
                            active_img: '/icons/category-white.svg'
                        },
                    ]
                },
                {
                    id: 17,
                    name: 'coupons',
                    text: 'coupons',
                    normal_img: '/icons/coupon-black.svg',
                    active_img: '/icons/coupon-white.svg'
                },
                {
                    id: 5,
                    name: 'orders',
                    text: 'orders',
                    normal_img: '/icons/order-black.svg',
                    active_img: '/icons/order-white.svg'
                },
                {
                    id: 6,
                    name: 'payments',
                    text: 'payments',
                    normal_img: '/icons/payment-black.svg',
                    active_img: '/icons/payment-white.svg'
                },
                {
                    id: 18,
                    name: 'plans',
                    text: 'plans',
                    normal_img: '/icons/plans-black.svg',
                    active_img: '/icons/plans-white.svg'
                },
                {
                    id: 7,
                    name: 'customers',
                    text: 'customers',
                    normal_img: '/icons/customer-black.svg',
                    active_img: '/icons/customer-white.svg'
                },
                {
                    id: 8,
                    name: 'account',
                    text: 'account',
                    normal_img: '/icons/profile-black.svg',
                    active_img: '/icons/profile-white.svg',
                    collapsable: true,
                    active: false,
                    options: [
                        {
                            id: 14,
                            name: 'privacy policy',
                            text: 'privacy policy',
                            normal_img: '/icons/product-black.svg',
                            active_img: '/icons/product-white.svg'
                        },
                        {
                            id: 15,
                            name: 'feedback',
                            text: 'feedback',
                            normal_img: '/icons/product-black.svg',
                            active_img: '/icons/product-white.svg'
                        },
                    ]
                },
            ],
            main_index: 0,
            sub_index: null
        };
    },
    props: ['selectedMenu'],
    watch: {
        selectedMenu(val) {
            if (val.id == 9) {
                this.setActive(4,0)
            }
        }
    },
    methods: {
        setActive(ind, sub_ind = null) {
            this.main_index = ind;
            this.sub_index = sub_ind;
            if (this.sub_index == null && this.sub_index != 0) {
                let selectedMenu = this.menues[this.main_index];
                if (this.menues[this.main_index].collapsable) {
                    this.collaps(this.main_index);
                    selectedMenu = this.menues[this.main_index].options[this.sub_index == null ? 0 : this.sub_index];
                }
                this.$emit('setNewActive', selectedMenu);
            }
            if (this.sub_index != null) {
                console.log(this.menues[this.main_index]);
                const selectedMenu = this.menues[this.main_index].options[this.sub_index];
                this.$emit('setNewActive', selectedMenu);
                // console.log(selectedMenu);
            }
        },
        async logout() {
            await this.$auth.logout();
            this.$router.push('/login');
        },
        collaps(ind) {
            this.menues[ind].active = !this.menues[ind].active;
        },
        async reloadSidebar() { 
            this.loader = true
            await this.fetchDashBoardData()
            this.loader = false
        },
        async fetchDashBoardData() {
            try {
                let query = `/get-stats`
                const response = await this.$axios.get(query)
                if (response.data.code == 401) {
                    await this.logout()
                    return false
                }
                const {
                    vendor_approval,
                    available_stores,
                    available_products,
                    available_banners,
                    available_addons,
                    available_sub_categories,
                    available_orders,
                    available_customers,
                    available_payments,
                    malls,
                    plans,
                    coupons,
                    // rejected_vendors,
                } = response.data.stats
                this.menues.forEach(e => {
                    if (e.options && e.options.length) {
                        e.options.forEach((el, ind) => {
                            if (el.name == 'sub-category') {
                                el.text = `sub-category (${available_sub_categories})`
                            }
                            if (el.name == 'addons') {
                                el.text = `addons (${available_addons})`
                            }
                            if (el.name == 'banners') {
                                el.text = `banners (${available_banners})`
                            }
                            if (el.name == 'products') {
                                el.text = `products (${available_products})`
                            }
                        })
                    }
                    if (e.name == 'customers') {
                        e.text = `customers (${available_customers})`  
                    }
                    if (e.name == 'payments') {
                        e.text = `payments (${available_payments})`  
                    }
                    if (e.name == 'orders') {
                        e.text = `orders (${available_orders})`  
                    }
                    if (e.name == 'malls') {
                        e.text = `malls (${malls})`  
                    }
                    if (e.name == 'coupons') {
                        e.text = `coupons (${coupons})`  
                    }
                    if (e.name == 'plans') {
                        e.text = `plans (${plans})`  
                    }
                    if (e.name == 'stores') {
                        e.text = `stores (${available_stores})`;
                    }
                    if (e.name == 'vendors') {
                        e.text = `vendors (${vendor_approval})`;
                    }
                })
            } catch (error) {
                console.log(error);
            }
        }
    },
    async mounted() {
        this.loader = true
        await this.fetchDashBoardData()
        this.loader = false
    },
    components: { Loader }
}
</script>
