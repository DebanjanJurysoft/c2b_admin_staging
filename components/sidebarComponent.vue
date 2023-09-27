<template>
    <b-sidebar
      id="sidebar-backdrop"
      title="Sidebar with backdrop"
      backdrop-variant="dark"
      no-close-on-backdrop
      backdrop
      shadow
      right
      no-header
      lazy
      no-footer
      :visible="visible"
      width="500px"
    >
    <div class="container">
        <!-- title section -->
        <div class="d-flex flex-row align-items-center justify-content-between">
            <span>{{ title }}</span>
            <i @click.prevent="emitClose" style="cursor: pointer;" class="fa fa-times text-danger"></i>
        </div>
        <div class="d-flex flex-column" v-if="product_details" style="overflow-y: auto;">
            <div class="product-details">
                <div class="product-image">
                    <img width="80" :src="product_details?.product_image" :alt="product_details?.product_name">
                </div>
                <div class="product-name-container">
                    <h3>{{ product_details?.product_name }}</h3>
                    <span>{{ product_details?.product_price }}</span>
                </div>
                <div class="product-quantity-container">
                    <h5>Total Item(s)</h5>
                    <span>{{ `${product_details?.product_quantity} Item(s)` }}</span>
                </div>
            </div>
            <div class="product_id" v-if="product_details?.product_id">
                <span>Product ID: {{ product_details?.product_id }}</span>
            </div>
            <div class="product_desc" v-if="product_details?.product_desc">
                <span>{{ product_details?.product_desc }}</span>
            </div>
            <div class="product_color" v-if="product_details?.product_colors">
                <span class="text">Color</span>
                <div class="colors-container flex-wrap">
                    <template v-for="(color, index) in product_details?.product_colors">
                        <div class="color" :style="`background: ${color.name}`"></div>
                    </template>
                </div>
            </div>
            <div class="product_size" v-if="product_details?.product_sizes">
                <span class="text">Size</span>
                <div class="sizes-container flex-wrap">
                    <template v-for="(size, index) in product_details?.product_sizes">
                        <div class="size">{{ size.name }}</div>
                    </template>
                </div>
            </div>
            <div class="product_specification" v-if="product_details?.product_specification">
                <span class="text">Specification</span>
                <ul>
                    <template v-for="(spec, index) in product_details?.product_specification">
                        <li>{{ spec }}</li>
                    </template>
                </ul>
            </div>
            <div class="product_negotiation" v-if="product_details?.product_negotiation">
                <div class="d-flex flex-row align-items-center justify-content-between">
                    <span class="product_negotiation_heading">{{ product_details?.product_negotiation.heading }}</span>
                    <i :class="product_details?.product_negotiation.icon"></i>
                </div>
                <span class="product_negotiation_text">{{ product_details?.product_negotiation.text }}</span>
            </div>
            <div class="product_delivery" v-if="product_details?.product_delivery_types">
                <template v-for="(del_type, del_index) in product_details?.product_delivery_types">
                    <div class="delivery" v-b-tooltip.hover :title="del_type.value ? 'Available' : 'Unavailable'" :class="del_type.value ? 'delivery-true' : 'delivery-false'">
                        {{ del_type.text }}
                    </div>
                </template>
            </div>
            <div class="product_address" v-if="product_details?.product_store_address">
                <span class="headi">Address: </span>
                <span class="text">{{ product_details?.product_store_address }}</span>
            </div>
        </div>
    </div>
    </b-sidebar>
</template>

<script>
export default {
    props: ['visible', 'title', 'product_details'],
    // data() {
    //     return {
    //         // title: 'Product Details',
    //         // product_details: {
    //         //     product_image: 'http://localhost:3030/uploads/categories/Food.svg',
    //         //     product_name: 'Food',
    //         //     product_price: '₹3,500',
    //         //     product_quantity: 1,
    //         //     product_id: '0010100102131652',
    //         //     product_desc: `Summer in the Cambodian flower market – that's the vibe this print channels.`,
    //         //     product_colors: [
    //         //         {
    //         //             name: 'purple',
    //         //             code: ''
    //         //         },
    //         //         {
    //         //             name: 'green',
    //         //             code: ''
    //         //         },
    //         //         {
    //         //             name: 'red',
    //         //             code: ''
    //         //         },
    //         //         {
    //         //             name: 'yellow',
    //         //             code: ''
    //         //         },
    //         //         {
    //         //             name: 'blue',
    //         //             code: ''
    //         //         },
    //         //         {
    //         //             name: 'black',
    //         //             code: ''
    //         //         },
    //         //         {
    //         //             name: 'white',
    //         //             code: ''
    //         //         }
    //         //     ],
    //         //     product_sizes: [
    //         //         {
    //         //             name: 'S',
    //         //         },
    //         //         {
    //         //             name: 'M',
    //         //         },
    //         //         {
    //         //             name: 'L',
    //         //         },
    //         //         {
    //         //             name: 'XL',
    //         //         },
    //         //         {
    //         //             name: '2XL',
    //         //         },
    //         //         {
    //         //             name: '3XL',
    //         //         }
    //         //     ],
    //         //     product_specification: [
    //         //         'Material: High-quality cotton blend',
    //         //         'Fit: Regular fit',
    //         //         'Pattern: Multi-color vertical stripes',
    //         //         'Collar: Classic button-down collar',
    //         //         'Sleeve: Full sleeves with button cuffs',
    //         //         'Closure: Front button closure',
    //         //         'Pocket: Single chest pocket',
    //         //         'Care Instructions: Machine wash cold, gentle cycle; do not bleach; tumble dry low; iron on low heat'
    //         //     ],
    //         //     product_negotiation: {
    //         //         heading: 'Negotiation',
    //         //         icon: 'fa fa-commenting-o',
    //         //         text: '"Negotiate for the best deal! Chat with the seller to discuss offers, discounts, and customizations before making your purchase."'
    //         //     },
    //         //     product_delivery_types: [
    //         //         {
    //         //             value: true,
    //         //             text: 'SELF PICKUP'
    //         //         },
    //         //         {
    //         //             value: true,
    //         //             text: 'DUNZO DELIVERY'
    //         //         },
    //         //         {
    //         //             value: false,
    //         //             text: 'VENDOR DELIVERY'
    //         //         },
    //         //     ],
    //         //     product_store_address: '453A, Javregowda Main Rd, Remco Bhel Layout, Javarandoddi, Rajarajeshwari Nagar, Bengaluru, Karnataka 560039'
    //         // }
    //     }
    // },
    methods: {
        emitClose() {
            this.$emit('openDetails')
        }
    }
}
</script>