<template>
    <div class="dashboard-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="line-chart-container">
        </div>
        <div v-if="!loader" class="information-cards-container">
            <div class="info-cards" v-for="(item, index) in dashboard_card_data" :key="index">
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
            loader: false,
            dashboard_card_data: [
                {
                    id: 1,
                    title: 'product approvals',
                    text: 'You have new 28 vendor product list to approve',
                    count: 28,
                    tag: 'today',
                    img_url: '/images/approved-products.svg'
                },
                {
                    id: 2,
                    title: 'Orders',
                    text: 'You have received total 54 orders today',
                    count: 54,
                    tag: 'today',
                    img_url: '/images/orders.svg'
                },
                {
                    id: 3,
                    title: 'vendor approvals',
                    text: 'You have new 17 vendor list to approve to platform',
                    count: 17,
                    tag: 'today',
                    img_url: '/images/vendor-approval.svg'
                },
                {
                    id: 4,
                    title: 'dismissed vendors',
                    text: 'You have dismissed total 25 vendor from last 6 months',
                    count: 25,
                    tag: 'last 6 months',
                    img_url: '/images/dismissed-vendors.svg'
                }
            ],
        }
    },
    mounted() { 
        this.loader = true
        setTimeout(() => {
            this.loader = false
        }, 100);
    }
}
</script>