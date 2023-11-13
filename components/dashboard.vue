<template>
    <div class="dashboard-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <!-- <div v-if="!loader" class="line-chart-container">
        </div> -->
        <div v-if="!loader" class="information-cards-container">
            <div class="info-cards cursor-pointer" v-for="(item, index) in dashboard_card_data" :key="index" @click.prevent="goToNav(item)">
                <div class="info-card-body">
                    <div class="data-container">
                        <h3>{{ item.title }}</h3>
                        <span>{{ item.count }}</span>
                        <p>{{ item.text }}</p>
                    </div>
                    <div class="image-container">
                        <div>
                            <span>{{ item.tag }}</span>
                        </div>
                        <img :src="item.img_url" :alt="item.title">
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import Loader from "./loader.vue"
export default {
    components: { Loader },
    data() {
        return {
            loader: true,
            chartData: {
                datasets: [{
                    label: 'Title',
                    data: [45, 55, 48, 35, 12]
                }]
            },
            dashboard_card_data: [
                {
                    id: 1,
                    title: 'product approvals',
                    text: 'You have new 28 vendor product list to approve',
                    count: 28,
                    navData: {
                        nav: {
                            id: 9,
                            name: 'products',
                            text: 'products',
                            normal_img: '/icons/product-black.svg',
                            active_img: '/icons/product-white.svg'
                        },
                    },
                    tag: 'today',
                    img_url: '/images/approved-products.svg'
                },
                {
                    id: 2,
                    title: 'Orders',
                    text: 'You have received total 54 orders today',
                    count: 54,
                    navData: {
                        nav: {
                            id: 5,
                            name: 'orders',
                            text: 'orders',
                            normal_img: '/icons/order-black.svg',
                            active_img: '/icons/order-white.svg'
                        },
                    },
                    tag: 'today',
                    img_url: '/images/orders.svg'
                },
                {
                    id: 3,
                    title: 'vendor approvals',
                    text: 'You have new 17 vendor list to approve to platform',
                    count: 17,
                    navData: {
                        nav: {
                            id: 2,
                            name: 'vendors',
                            text: 'vendors',
                            normal_img: '/icons/vendor-black.svg',
                            active_img: '/icons/vendor-white.svg'
                        },
                    },
                    tag: 'today',
                    img_url: '/images/vendor-approval.svg'
                },
                {
                    id: 4,
                    title: 'dismissed vendors',
                    text: 'You have dismissed total 25 vendor from last 6 months',
                    count: 25,
                    navData: {
                        nav: {
                            id: 2,
                            name: 'vendors',
                            text: 'vendors',
                            normal_img: '/icons/vendor-black.svg',
                            active_img: '/icons/vendor-white.svg'
                        },
                        inner_nav: {
                            id: 3,
                            name: 'vendors_disapproved',
                            text: 'disapproved vendors'
                        },
                    },
                    tag: 'last 6 months',
                    img_url: '/images/dismissed-vendors.svg'
                }
            ],
        }
    },
    async mounted() { 
        this.loader = true
        await this.fetchDashBoardData()
        this.loader = false
    },
    methods: {
        goToNav(item) {
            localStorage.setItem('navData', JSON.stringify(item.navData))
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
                    available_products,
                    available_orders,
                    rejected_vendors,
                    vendor_approval
                } = response.data.stats
                this.dashboard_card_data[0].count = available_products
                this.dashboard_card_data[0].text = `You have new ${available_products} vendor product list to approve`
                this.dashboard_card_data[1].count = available_orders
                this.dashboard_card_data[1].text = `You have received total ${available_orders} orders today`
                this.dashboard_card_data[2].count = vendor_approval
                this.dashboard_card_data[2].text = `You have new ${vendor_approval} vendor list to approve to platform`
                this.dashboard_card_data[3].count = rejected_vendors
                this.dashboard_card_data[3].text = `You have dismissed total ${rejected_vendors} vendor from last 6 months`
            } catch (error) {
                console.log(error);
            }
        }
    }
}
</script>