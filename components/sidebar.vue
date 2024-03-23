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
                    <div v-if="nav.has_permission" class="nav-items d-flex justify-content-between" :class="nav.id == selectedMenu.id ? 'nav-items-active' : nav.collapsable && !nav.active && nav.options.includes(selectedMenu) ? 'nav-items-active' : ''" :key="ind" @click.prevent="setActive(ind)">
                        <div>
                            <img :src="`${nav.id == selectedMenu.id ? nav.active_img : nav.collapsable && !nav.active && nav.options.includes(selectedMenu) ? nav.active_img : nav.normal_img}`" alt="image">
                            <span>{{ nav.text }}</span>
                        </div>
                        <i v-if="nav.collapsable && !nav.active" class="fa fa-angle-down"></i>
                        <i v-if="nav.collapsable && nav.active" class="fa fa-angle-up"></i>
                    </div>
                    <template v-for="(nav_sub, nav_sub_ind) in nav.options" v-if="nav.active && nav_sub.has_permission">
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
        <span class="logout-button" @click.prevent="logout(true)">
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
            super_admin_psermissions: [
                {
                    module_name: 'home',
                    has_permission: true
                },
                {
                    module_name: 'vendors',
                    has_permission: true
                },
                {
                    module_name: 'service_provider',
                    has_permission: true
                },
                {
                    module_name: 'stores',
                    has_permission: true
                },
                {
                    module_name: 'malls',
                    has_permission: true
                },
                {
                    module_name: 'inventory',
                    has_permission: true
                },
                {
                    module_name: 'products',
                    has_permission: true
                },
                {
                    module_name: 'banners',
                    has_permission: true
                },
                {
                    module_name: 'addons',
                    has_permission: true
                },
                {
                    module_name: 'sub-category',
                    has_permission: true
                },
                {
                    module_name: 'category',
                    has_permission: true
                },
                {
                    module_name: 'attributes',
                    has_permission: true
                },
                {
                    module_name: 'coupons',
                    has_permission: true
                },
                {
                    module_name: 'orders',
                    has_permission: true
                },
                {
                    module_name: 'payments',
                    has_permission: true
                },
                {
                    module_name: 'plans',
                    has_permission: true
                },
                {
                    module_name: 'notifications',
                    has_permission: true
                },
                {
                    module_name: 'reports',
                    has_permission: true
                },
                {
                    module_name: 'services',
                    has_permission: true
                },
                {
                    module_name: 'customers',
                    has_permission: true
                },
                {
                    module_name: 'account',
                    has_permission: true
                },
                {
                    module_name: 'privacy policy',
                    has_permission: true
                },
                {
                    module_name: 'feedback',
                    has_permission: true
                },
                {
                    module_name: 'admins',
                    has_permission: true
                },
                {
                    module_name: 'admin permissions',
                    has_permission: true
                },
            ],
            menues: [
                {
                    id: 1,
                    name: 'home',
                    text: 'home',
                    noSearch: true,
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
                    id: 26,
                    name: 'service_provider',
                    text: 'service provider',
                    noSearch: true,
                    normal_img: '/icons/service_provider-black.svg',
                    active_img: '/icons/service_provider-white.svg'
                },
                {
                    id: 4,
                    name: 'inventory',
                    noSearch: true,
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
                            noSearch: true,
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
                            id: 26,
                            name: 'category',
                            text: 'category',
                            noSearch: true,
                            normal_img: '/icons/category-black.svg',
                            active_img: '/icons/category-white.svg'
                        },
                        {
                            id: 13,
                            name: 'sub-category',
                            text: 'sub-category',
                            noSearch: true,
                            normal_img: '/icons/sub-category-black.svg',
                            active_img: '/icons/sub-category-white.svg'
                        },
                        {
                            id: 22,
                            name: 'attributes',
                            text: 'attributes',
                            noSearch: true,
                            normal_img: '/icons/layer-black.svg',
                            active_img: '/icons/layer-white.svg'
                        },
                        {
                            id: 25,
                            name: 'services',
                            text: 'services',
                            noSearch: true,
                            normal_img: '/icons/services-black.svg',
                            active_img: '/icons/services-white.svg'
                        },
                    ]
                },
                {
                    id: 19,
                    name: 'malls',
                    text: 'malls',
                    normal_img: '/icons/malls-black.svg',
                    active_img: '/icons/malls-white.svg'
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
                    // noSearch: true,
                    normal_img: '/icons/order-black.svg',
                    active_img: '/icons/order-white.svg'
                },
                {
                    id: 6,
                    name: 'payments',
                    text: 'payments',
                    noSearch: true,
                    normal_img: '/icons/payment-black.svg',
                    active_img: '/icons/payment-white.svg'
                },
                {
                    id: 18,
                    name: 'plans',
                    text: 'plans',
                    noSearch: true,
                    normal_img: '/icons/plans-black.svg',
                    active_img: '/icons/plans-white.svg'
                },
                {
                    id: 20,
                    name: 'notifications',
                    text: 'notifications',
                    noSearch: true,
                    normal_img: '/icons/notification-black.svg',
                    active_img: '/icons/notification-white.svg'
                },
                {
                    id: 21,
                    name: 'reports',
                    text: 'reports',
                    noSearch: true,
                    normal_img: '/icons/reports-black.svg',
                    active_img: '/icons/reports-white.svg'
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
                    noSearch: true,
                    normal_img: '/icons/profile-black.svg',
                    active_img: '/icons/profile-white.svg',
                    collapsable: true,
                    active: false,
                    options: [
                        {
                            id: 14,
                            name: 'privacy policy',
                            text: 'privacy policy',
                            noSearch: true,
                            normal_img: '/icons/product-black.svg',
                            active_img: '/icons/product-white.svg'
                        },
                        {
                            id: 15,
                            name: 'feedback',
                            text: 'feedback',
                            noSearch: true,
                            normal_img: '/icons/product-black.svg',
                            active_img: '/icons/product-white.svg'
                        },
                    ]
                },
                {
                    id: 23,
                    name: 'admins',
                    text: 'admins',
                    noSearch: true,
                    normal_img: '/icons/admin-black.svg',
                    active_img: '/icons/admin-white.svg'
                },
                {
                    id: 24,
                    name: 'admin permissions',
                    text: 'admin permissions',
                    noSearch: true,
                    normal_img: '/icons/permission-black.svg',
                    active_img: '/icons/permission-white.svg'
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
        async fetchPermissions() {
            try {
                const response = await this.$axios.get('/get-user')
                if (response.data.code == 401) {
                    await this.logout()
                    return false
                }
                const permissions = response.data.user.super ? this.super_admin_psermissions : response.data.user.permissions
                let outer_index = 0
                for (const modules of this.menues) {
                    const available_permissions = permissions.find(e => e.module_name == modules.name)
                    this.menues[outer_index].has_permission = available_permissions ? available_permissions.has_permission : false
                    if (modules.collapsable) {
                        let collaps_index = 0
                        for (const collaps of modules.options) {
                            const available_inner_permissions = permissions.find(e => e.module_name == collaps.name)
                            this.menues[outer_index].options[collaps_index].has_permission = available_inner_permissions ? available_inner_permissions.has_permission : false
                            if (this.menues[outer_index].options[collaps_index].has_permission) {
                                this.menues[outer_index].has_permission = true
                            }
                            collaps_index = collaps_index + 1
                        }
                    }
                    if (modules.collapsable) {
                        let has_permission = false
                        for (const collaps of modules.options) {
                            const available_inner_permissions = permissions.find(e => e.module_name == collaps.name)
                            if (!has_permission) {
                                has_permission = available_inner_permissions ? available_inner_permissions.has_permission : false
                            }
                        }
                        this.menues[outer_index].has_permission = has_permission
                    }
                    outer_index = outer_index + 1
                }
            } catch (error) {
                console.log(error);
            }
        },
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
        async logout(force = false) {
            localStorage.removeItem('token')
            if (force) {
                localStorage.removeItem('refreshToken')
            }
            this.$router.push('/login')
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
                console.log('fetchDashBoardData');
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
        const token = localStorage.getItem('token')
        if (!token) {
            console.log(token);
            // await this.$auth.logout()
            this.$router.push('/login')
        } else {
            this.$axios.setHeader('Authorization', token)
        }
        await this.fetchPermissions()
        await this.fetchDashBoardData()
        this.loader = false
    },
    components: { Loader }
}
</script>
