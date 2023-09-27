<template>
    <div class="order-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="order-tabs">
            <div class="tab-items" @click.prevent="changeTab(index)" :class="selected_tab.id == tab.id ? 'tab-items-active' : ''" v-for="(tab, index) in tabs" :key="index">
                <span>{{ tab.text }}</span>
            </div>
        </div>
        <div v-if="!loader" class="tabs-content">
            <div class="d-flex flex-row">
                <div class="w-75">
                    <label class="mr-3">Rows:</label>
                    <b-form-select style="width: 100px;" v-model="per_page" :options="per_page_options"></b-form-select>
                </div>
                <div class="w-25">
                    <!-- top pagination  -->
                    <Pagination @changePage="changePage" :data_list="orders" :per_page="per_page" :total_rows="order_total" :page="page"/>
                </div>
            </div>
            <Table @openDetails="openDetails" :headings="order_headings" :data_rows="orders" />
            <Pagination @changePage="changePage" :data_list="orders" :per_page="per_page" :total_rows="order_total" :page="page"/>
            <SidebarComponent @openDetails="openDetails" :visible="show_details" :title="'Product Details'" :product_details="product_details"/>
        </div>
    </div>
</template>
<script>
export default {
    props: ['searchText'],
    data() {
        return {
            loader: false,
            selected_tab: {
                id: 1,
                name: 'accepted_orders',
                text: 'Accepted orders'
            },
            tabs: [
                {
                    id: 1,
                    name: 'accepted_orders',
                    text: 'accepted orders'
                },
                {
                    id: 2,
                    name: 'rejected_orders',
                    text: 'rejected orders'
                },
                {
                    id: 3,
                    name: 'delivered_products',
                    text: 'delivered orders'
                },
            ],
            orders: [],
            order_headings: [],
            order_total: 0,
            accepted_orders: [],
            accepted_order_heading: [
                {
                    name: 'vendor name',
                    icon: 'fa fa-shopping-basket'
                },
                {
                    name: 'store name',
                    icon: 'fa fa-shopping-basket'
                },
                {
                    name: 'order id',
                    icon: 'bx bxs-package',
                    onclick: true
                },
                {
                    name: 'product name',
                    icon: 'fa fa-product-hunt',
                    onclick: true
                },
                {
                    name: 'product id',
                    icon: 'fa fa-product-hunt',
                    onclick: true
                },
                {
                    name: 'quantity',
                    icon: 'fa fa-times'
                },
                {
                    name: 'unit price',
                    icon: 'fa fa-times'
                },
                {
                    name: 'total price',
                    icon: 'fa fa-times'
                },
                {
                    name: 'delivery type',
                    icon: 'bx bx-package'
                },
                {
                    name: 'date',
                    icon: 'fa fa-calendar-o'
                },
                {
                    name: 'time',
                    icon: 'fa fa-clock-o'
                },
            ],
            rejected_order_total: 0,
            rejected_orders: [],
            rejected_order_heading: [
                {
                    name: 'vendor name',
                    icon: 'fa fa-shopping-basket'
                },
                {
                    name: 'store name',
                    icon: 'fa fa-shopping-basket'
                },
                {
                    name: 'order id',
                    icon: 'bx bxs-package',
                    onclick: true
                },
                {
                    name: 'product name',
                    icon: 'fa fa-product-hunt',
                    onclick: true
                },
                {
                    name: 'product id',
                    icon: 'fa fa-product-hunt',
                    onclick: true
                },
                {
                    name: 'quantity',
                    icon: 'fa fa-times'
                },
                {
                    name: 'unit price',
                    icon: 'fa fa-times'
                },
                {
                    name: 'total price',
                    icon: 'fa fa-times'
                },
                {
                    name: 'delivery type',
                    icon: 'bx bx-package'
                },
                {
                    name: 'date',
                    icon: 'fa fa-calendar-o'
                },
                {
                    name: 'time',
                    icon: 'fa fa-clock-o'
                },
            ],
            delivered_order_total: 0,
            delivered_orders: [],
            delivered_order_heading: [
                {
                    name: 'vendor name',
                    icon: 'fa fa-shopping-basket'
                },
                {
                    name: 'store name',
                    icon: 'fa fa-shopping-basket'
                },
                {
                    name: 'order id',
                    icon: 'bx bxs-package',
                    onclick: true
                },
                {
                    name: 'product name',
                    icon: 'fa fa-product-hunt',
                    onclick: true
                },
                {
                    name: 'product id',
                    icon: 'fa fa-product-hunt',
                    onclick: true
                },
                {
                    name: 'quantity',
                    icon: 'fa fa-times'
                },
                {
                    name: 'unit price',
                    icon: 'fa fa-times'
                },
                {
                    name: 'total price',
                    icon: 'fa fa-times'
                },
                {
                    name: 'delivery type',
                    icon: 'bx bx-package'
                },
                {
                    name: 'date',
                    icon: 'fa fa-calendar-o'
                },
                {
                    name: 'time',
                    icon: 'fa fa-clock-o'
                },
            ],
            accepted_order_total: 0,
            per_page: 7,
            page: 1,
            per_page_options: Array.from(Array(15).keys()).map(e => e + 1),
            product_details: null,
            show_details: false,
        }
    },
    async mounted() {
        await this.mountedMethod()
        this.changeTab(0)
    },
    watch: {
        per_page() {
            this.changePage(this.page)
        },
    },
    methods: {
        async openDetails(data) {
            const index = parseInt(data)
            this.product_details = {}
            if (!this.show_details) {
                const selectedData = this.orders[index]
                this.product_details = {
                    product_image: 'http://localhost:3030/uploads/categories/Food.svg',
                    product_name: selectedData['product name'],
                    product_price: selectedData['unit price'],
                    product_quantity: selectedData['quantity'],
                    product_id: selectedData['product id'],
                    product_desc: selectedData.full_data.product.description,
                    product_colors: selectedData.full_data.product.color ? [{
                        name: selectedData.full_data.product.color,
                    }] : null,
                    product_sizes: selectedData.full_data.product.size ? [{
                        name: selectedData.full_data.product.size[0].toUpperCase()
                    }] : null,
                    product_specification: selectedData.full_data.product.specifications ? selectedData.full_data.product.specifications.split(',') : null,
                    product_negotiation: selectedData.full_data.negotiation ? {
                        heading: 'Negotiation',
                        icon: 'fa fa-commenting-o',
                        text: 'Negotiate for the best deal! Chat with the seller to discuss offers, discounts, and customizations before making your purchase.',
                    } : null,
                    product_delivery_types: [
                        {
                            text: 'SELF PICKUP'
                        },
                        {
                            text: 'DUNZO DELIVERY'
                        },
                        {
                            text: 'SELLER DELIVERY'
                        },
                    ].map(e => {
                        if (e.text == selectedData['delivery type']) {
                            return {
                                value: true,
                                ...e
                            }
                        } else {
                            return {
                                value: false,
                                ...e
                            }
                        }
                    }),
                }
            }
            this.show_details = !this.show_details
        },
        async changePage(page_no) {
            this.page = page_no
            switch (this.selected_tab.id) {
                case 1:
                    await this.fetchAcceptedOrders()
                    this.order_headings = this.accepted_order_heading
                    this.orders = this.accepted_orders
                    this.order_total = this.accepted_order_total
                    break;
                case 2:
                    // await this.fetchApprovedVendors()
                    break;
                case 3:
                    // await this.fetchRejectedVendors()
                    break;
            }
            window.scrollTo(0, 0);
            this.loader = false
        },
        async mountedMethod() {
            this.loader = true
            await this.fetchAcceptedOrders()
            await this.fetchRejectedOrders()
            await this.fetchDeliveredOrders()
            this.loader = false
        },
        async changeTab(index) { 
            this.page = 1
            await this.mountedMethod()
            this.selected_tab = this.tabs[index]
            switch (index) {
                case 0:
                    this.order_headings = this.accepted_order_heading
                    this.orders = this.accepted_orders
                    this.order_total = this.accepted_order_total
                    break;
                case 1:
                    this.order_headings = this.rejected_order_heading
                    this.orders = this.rejected_orders
                    this.order_total = this.rejected_order_total
                    break
                case 2:
                    this.order_headings = this.delivered_order_heading
                    this.orders = this.delivered_orders
                    this.order_total = this.delivered_order_total
                    break
            
                default:
                    break;
            }
            this.loader = false
        },
        async logout() {
            await this.$auth.logout()
            this.$router.push('/login')
        },
        async fetchAcceptedOrders() {
            let query = `/fetch-orders-admin?page=${this.page ? this.page : 1}&per_page=${this.per_page}`
            if (this.searchText && this.searchText != '') {
                query = query + `&q=${this.searchText}`
            }
            const response = await this.$axios.get(query)
            if (response.data.code == 401) {
                await this.logout()
            }
            this.accepted_order_total = response.data.total
            this.accepted_orders = response.data.orders.map(order => {
                return {
                    'vendor name': order.product.vendor.fullname,
                    'store name': order.product.vendor.store.name,
                    'order id': order.order.ord_id,
                    'product name': order.product.name,
                    'product id': `${order.category_table_association.category_name}-${order.product.id}`,
                    'product category': order.category_table_association.category_name,
                    'quantity': order.quantity,
                    'unit price':`₹ ${parseFloat(order.product.price).toLocaleString('en-IN')}`,
                    'total price': `₹ ${(parseFloat(order.quantity) * parseFloat(order.product.price)).toLocaleString('en-IN')}`,
                    'delivery type': order.delivery_type.type,
                    'date': order.createdAt ? new Date(order.createdAt).toLocaleDateString() : 'N/A',
                    'time': order.createdAt ? new Date(order.createdAt).toLocaleTimeString() : 'N/A',
                    total_price: (parseFloat(order.quantity) * parseFloat(order.product.price)),
                    unit_ptice: parseFloat(order.product.price),
                    quantity: order.quantity,
                    id: order.id,
                    full_data: order
                }
            })
            this.tabs.forEach(e => {
                if (e.name == 'accepted_orders') {
                    e.text = `accepted orders (${this.accepted_order_total})`  
                }
            })
        },
        async fetchRejectedOrders() {
            let query = `/fetch-orders-admin?page=${this.page ? this.page : 1}&per_page=${this.per_page}&status=13`
            if (this.searchText && this.searchText != '') {
                query = query + `&q=${this.searchText}`
            }
            const response = await this.$axios.get(query)
            if (response.data.code == 401) {
                await this.logout()
            }
            this.rejected_order_total = response.data.total
            this.rejected_orders = response.data.orders.map(order => {
                return {
                    'vendor name': order.product.vendor.fullname,
                    'store name': order.product.vendor.store.name,
                    'order id': order.order.ord_id,
                    'product name': order.product.name,
                    'product id': `${order.category_table_association.category_name}-${order.product.id}`,
                    'product category': order.category_table_association.category_name,
                    'quantity': order.quantity,
                    'unit price':`₹ ${parseFloat(order.product.price).toLocaleString('en-IN')}`,
                    'total price': `₹ ${(parseFloat(order.quantity) * parseFloat(order.product.price)).toLocaleString('en-IN')}`,
                    'delivery type': order.delivery_type.type,
                    'date': order.createdAt ? new Date(order.createdAt).toLocaleDateString() : 'N/A',
                    'time': order.createdAt ? new Date(order.createdAt).toLocaleTimeString() : 'N/A',
                    total_price: (parseFloat(order.quantity) * parseFloat(order.product.price)),
                    unit_ptice: parseFloat(order.product.price),
                    quantity: order.quantity,
                    id: order.id,
                    full_data: order
                }
            })
            this.tabs.forEach(e => {
                if (e.name == 'rejected_orders') {
                    e.text = `rejected orders (${this.rejected_order_total})`  
                }
            })
        },
        async fetchDeliveredOrders() {
            let query = `/fetch-orders-admin?page=${this.page ? this.page : 1}&per_page=${this.per_page}&status=4`
            if (this.searchText && this.searchText != '') {
                query = query + `&q=${this.searchText}`
            }
            const response = await this.$axios.get(query)
            if (response.data.code == 401) {
                await this.logout()
            }
            this.delivered_order_total = response.data.total
            this.delivered_orders = response.data.orders.map(order => {
                return {
                    'vendor name': order.product.vendor.fullname,
                    'store name': order.product.vendor.store.name,
                    'order id': order.order.ord_id,
                    'product name': order.product.name,
                    'product id': `${order.category_table_association.category_name}-${order.product.id}`,
                    'product category': order.category_table_association.category_name,
                    'quantity': order.quantity,
                    'unit price':`₹ ${parseFloat(order.product.price).toLocaleString('en-IN')}`,
                    'total price': `₹ ${(parseFloat(order.quantity) * parseFloat(order.product.price)).toLocaleString('en-IN')}`,
                    'delivery type': order.delivery_type.type,
                    'date': order.createdAt ? new Date(order.createdAt).toLocaleDateString() : 'N/A',
                    'time': order.createdAt ? new Date(order.createdAt).toLocaleTimeString() : 'N/A',
                    total_price: (parseFloat(order.quantity) * parseFloat(order.product.price)),
                    unit_ptice: parseFloat(order.product.price),
                    quantity: order.quantity,
                    id: order.id,
                    full_data: order
                }
            })
            this.tabs.forEach(e => {
                if (e.name == 'delivered_products') {
                    e.text = `delivered orders (${this.delivered_order_total})`  
                }
            })
        }
    }
}
</script>