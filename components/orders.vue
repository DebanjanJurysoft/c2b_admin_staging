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
            <div class="d-flex flex-row align-items-center">
                <div class="w-75 d-flex flex-row align-items-center" style="gap: 10px;">
                    <label class="mr-3">Rows:</label>
                    <b-form-select style="width: 100px;" v-model="per_page" :options="per_page_options"></b-form-select>
                    <button 
                        v-b-tooltip.hover
                        title="Reload"
                        class="button" 
                        @click.prevent="mountedMethod(selected_tab.id)"><i class="fa fa-refresh"></i></button>
                </div>
                <div class="w-25">
                    <!-- top pagination  -->
                    <Pagination @changePage="changePage" :data_list="orders" :per_page="per_page" :total_rows="order_total" :page="page"/>
                </div>
            </div>
            <Table @openSpecific="openSpecific" @openDetails="openDetails" :headings="order_headings" :data_rows="orders"  :file_name="`${selected_tab.name}_list.csv`" :page="page" :rows="per_page"/>
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
                    id: 4,
                    name: 'pending_orders',
                    text: 'pending orders'
                },
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
                    name: 'Order Status',
                    icon: 'fa fa-check',
                    type: 'DROPDOWN',
                    onclick: true,
                    onclick_emit: 'changeStatus'
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
            pending_order_total: 0,
            pending_orders: [],
            pending_order_heading: [
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
                    name: 'Accept/Reject',
                    icon: 'fa fa-first-order',
                    type: 'DROPDOWN',
                    onclick: true,
                    dropdown_data: [
                        {
                            value: true,
                            text: 'Accept'
                        },
                        {
                            value: false,
                            text: 'Reject'
                        },
                    ],
                    onclick_emit: 'accept_reject'
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
            per_page: 5,
            page: 1,
            per_page_options: Array.from(Array(15).keys()).map(e => e + 1),
            product_details: null,
            show_details: false,
            order_status_list: [],
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
        async updateStatus(order_details_id, status_id) {
            try {
                this.loader = true
                const data = {
                    order_details_id,
                    status_id
                }
                const response = await this.$axios.post('/change-order-status', data)
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                await this.mountedMethod()
                this.loader = false
            } catch (error) {
                console.log(error);
            }
        },
        async fetchorderStatus() {
            try {
                const response = await this.$axios.get('/fetch-order-status')
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.order_status_list = response.data.order_statuses.map(e => {
                    return {
                        value: e.id,
                        text: e.status_name
                    }
                })
                this.pending_order_heading.forEach(e => {
                    if (e.name == 'Order Status') {
                        e['dropdown_data'] = this.order_status_list
                    }
                })
                this.accepted_order_heading.forEach(e => {
                    if (e.name == 'Order Status') {
                        e['dropdown_data'] = this.order_status_list
                    }
                })
            } catch (error) {
                console.log(error);
            }
        },
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
                    await this.fetchRejectedOrders()
                    this.order_headings = this.rejected_order_heading
                    this.orders = this.rejected_orders
                    this.order_total = this.rejected_order_total
                    break;
                case 3:
                    await this.fetchDeliveredOrders()
                    this.order_headings = this.delivered_order_heading
                    this.orders = this.delivered_orders
                    this.order_total = this.delivered_order_total
                    break;
                case 4:
                    await this.fetchPendingOrders()
                    this.order_headings = this.pending_order_heading
                    this.orders = this.pending_orders
                    this.order_total = this.pending_order_total
                    break;
            }
            window.scrollTo(0, 0);
            this.loader = false
        },
        async openSpecific(data) { 
            if (data.type == 'accept_reject') {
                if (data.data["Accept/Reject"] !== null && data.data["Accept/Reject"] !== undefined) await this.accept_reject(data)
            }
            if (data.type == 'changeStatus') {
                await this.updateStatus(data.data.id, data.data['Order Status'])
            }
        },
        async accept_reject(data) { 
            console.log(data);
            this.loader = true
            const response = await this.$axios.post('/accept-reject-order-vendor', {
                order_details_id: data.data.id,
                accept: data.data['Accept/Reject']
            })
            this.$toast.show(response.data.message, {
                duration: 1500,
                position: 'top-right',
                keepOnHover: true,
                type: response.data.status
            })
            await this.mountedMethod()
            if (data.data['Accept/Reject'])this.changeTab(1)
            else this.changeTab(2)
            this.loader = false
        },
        async mountedMethod(tab = null) {
            this.loader = true
            switch (tab) {
                case null:
                    await this.fetchPendingOrders()
                    await this.fetchAcceptedOrders()
                    await this.fetchRejectedOrders()
                    await this.fetchDeliveredOrders()
                    await this.fetchorderStatus()
                    break;
                    
                case 1:
                    await this.fetchAcceptedOrders()
                    await this.fetchorderStatus()
                    break;
                    
                case 2:
                    await this.fetchRejectedOrders()
                    break;
                
                case 3:
                    await this.fetchDeliveredOrders()
                    break;

                
                case 4:
                    await this.fetchPendingOrders()
                    break;

                default:
                    break;
            }
            
            this.loader = false
        },
        async changeTab(index) { 
            this.page = 1
            this.selected_tab = this.tabs[index]
            await this.mountedMethod(this.selected_tab.id)
            switch (this.selected_tab.id) {
                case 1:
                    this.order_headings = this.accepted_order_heading
                    this.orders = this.accepted_orders
                    this.order_total = this.accepted_order_total
                    break;
                case 2:
                    this.order_headings = this.rejected_order_heading
                    this.orders = this.rejected_orders
                    this.order_total = this.rejected_order_total
                    break
                case 3:
                    this.order_headings = this.delivered_order_heading
                    this.orders = this.delivered_orders
                    this.order_total = this.delivered_order_total
                    break
                case 4:
                    this.order_headings = this.pending_order_heading
                    this.orders = this.pending_orders
                    this.order_total = this.pending_order_total
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
        async fetchPendingOrders() {
            let query = `/fetch-orders-admin?page=${this.page ? this.page : 1}&per_page=${this.per_page}`
            if (this.searchText && this.searchText != '') {
                query = query + `&q=${this.searchText}`
            }
            const response = await this.$axios.get(query)
            if (response.data.code == 401) {
                await this.logout()
            }
            console.log(response.data);
            this.pending_order_total = response.data.total
            this.pending_orders = response.data.orders.map(order => {
                return {
                    'vendor name': order.product.vendor.fullname,
                    'store name': order.product.vendor.store.name,
                    'order id': order.order.ord_id,
                    'product name': order.product.name,
                    'product id': `${order.category_table_association.category_name}-${order.product.id}`,
                    'product category': order.category_table_association.category_name,
                    'quantity': order.quantity,
                    'accept/reject': order.accepted,
                    'unit price':`₹ ${parseFloat(order.product.price).toLocaleString('en-IN')}`,
                    'total price': `₹ ${(parseFloat(order.quantity) * parseFloat(order.product.price)).toLocaleString('en-IN')}`,
                    'delivery type': order.delivery_type.type,
                    'date': order.createdAt ? new Date(order.createdAt).toLocaleDateString() : 'N/A',
                    'time': order.createdAt ? new Date(order.createdAt).toLocaleTimeString() : 'N/A',
                    'Order Status': order.order_status_id ? order.order_status_id : null,
                    total_price: (parseFloat(order.quantity) * parseFloat(order.product.price)),
                    unit_ptice: parseFloat(order.product.price),
                    quantity: order.quantity,
                    id: order.id,
                    full_data: order
                }
            })
            this.tabs.forEach(e => {
                if (e.name == 'pending_orders') {
                    e.text = `pending orders (${this.pending_order_total})`  
                }
            })
        },
        async fetchAcceptedOrders() {
            let query = `/fetch-orders-admin?page=${this.page ? this.page : 1}&per_page=${this.per_page}&accepted=true`
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
                    'Order Status': order.order_status_id ? order.order_status_id : null,
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
            let query = `/fetch-orders-admin?page=${this.page ? this.page : 1}&per_page=${this.per_page}&status=13&accepted=false`
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
            let query = `/fetch-orders-admin?page=${this.page ? this.page : 1}&per_page=${this.per_page}&status=4&accepted=true`
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