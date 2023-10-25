<template>
    <div class="category-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="tabs-content">
            <div class="d-flex flex-row w-100" style="gap: 30px">
                <div class="d-flex flex-column w-50" style="gap: 10px;  height: 100% !important; overflow-y: scroll;">
                    <div class="d-flex flex-row align-items-center justify-content-between">
                        <h1 class="heading" style="font-size: 20px; background: none; border: none; color: black;">Stores</h1>
                    </div>
                    <div class="card" v-for="(store, store_index) in store_list" style="border-radius: 16px;" @click.prevent="showStoreForIndex(store_index)" >
                        <div class="d-flex flex-row py-3 pl-5 pr-3 justify-content-between align-items-center" :style="store_index == selected_store_index ? 'border-radius: 16px; border: 2px solid #e74c3c; box-shadow: 0px 0px 12px 0px rgba(0, 0, 0, 0.12);' : ''">
                            <div class="d-flex flex-row" style="gap: 10px;">
                                <img style="border-radius: 16px; height: 60px !important; width: 100px !important; object-fit: cover;" :src="store.store_image_url" width="100" alt="Image">
                                <div class="d-flex flex-column">
                                    <span class="heading" style="font-size: 16px; background: none; border: none;" >Store: {{ store.name }}</span>
                                    <span class="heading" style="font-size: 12px; line-height: 1px; background: none; border: none;">Vendor: {{ store?.vendor?.fullname ? store?.vendor?.fullname : 'N/A' }}</span>
                                </div>
                            </div>
                            <i 
                                v-b-tooltip.hover
                                title="Branches"
                                class="fa fa-sitemap"
                                style="font-size: 20px; background: none; border: none; color: #667085;"
                            ></i>
                        </div>
                    </div>
                </div>
                <div class="d-flex flex-column w-50 p-2" style="gap: 10px;  height: 100% !important; overflow-y: scroll;" v-if="selected_store_index != null && !open_form">
                    <div class="d-flex flex-row align-items-center justify-content-between">
                        <h1 class="text-heading" style="font-size: 20px; background: none; border: none; color: black;">Branches ({{ branch_list.length }})</h1>
                        <i @click.prevent="openCreateForm" style="font-size: 18px;" class="fa fa-plus-circle text-success cursor-pointer" aria-hidden="true"></i>
                    </div>
                    <div class="card sub-category-form" v-for="(branch, branch_index) in branch_list" :key="branch_index">
                        <div class="d-flex flex-row" :class="branch.collapse_active ? 'mb-3' : ''">
                            <div style="width: 25% !important;">
                                <img style="border-radius: 16px; height: 60px !important;  width: 100px !important; object-fit: cover;" :src="branch.image_url" alt="Branch Image" >
                            </div>
                            <div style="width: 65% !important" class="d-flex flex-row align-items-center">
                                <span class="heading" style="font-size: 20px; background: none; border: none;" >{{ branch.branch_name }}</span>
                            </div>
                            <div style="width: 10% !important;" class="d-flex flex-row align-items-center float-right">
                                <i @click.prevent="openBranchDetails(branch, branch_index)" :class="branch.collapse_active ? 'fa fa-angle-up' : 'fa fa-angle-down'"></i>
                            </div>
                        </div>
                        <div class="d-flex flex-column" v-if="branch.collapse_active">
                            <div class="card d-flex flex-row align-items-center justify-content-between" style="border-radius: 16px;" v-for="(product, branch_product_index) in branch_product_list" :key="branch_product_index">
                                <div class="d-flex flex-row align-items-center p-2">
                                    <img style="border-radius: 16px; height: 60px !important; width: 100px !important; object-fit: cover;" :src="product.product.images_of_products.length ? product.product.images_of_products[0].image_url : ''" alt="Image" >
                                    <div class="d-flex flex-column">
                                        <span class="text-heading">{{ product.product.name }}</span>
                                        <span style="margin-top: -15px;" class="text-heading">Price: {{ product.product.price }}</span>
                                    </div>
                                </div>
                                <span>
                                    <b-form-checkbox v-model="product.active" switch></b-form-checkbox>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="d-flex flex-column w-50" style="gap: 10px;  height: 100% !important; overflow-y: scroll;" v-else-if="open_form">
                    <div class="d-flex sub-category-form flex-column" style="gap: 10px">
                        <div class="d-flex flex-row align-items-center justify-content-between">
                            <h1 class="heading" style="font-size: 16px; width: 100% !important; background: none; border: none; color: black;">{{ edit_id ? 'Edit Branch' : 'Add Branch' }}</h1>
                            <i @click.prevent="closeForm" style="font-size: 20px;" class="fa fa-times-circle text-danger cursor-pointer" aria-hidden="true"></i>
                        </div>
                        <div class="d-flex flex-column px-3">
                            <b-form-group
                                label="Branch Name"
                                class="mb-0"
                            >
                                <b-form-input type="text" v-model="create_branch_data.branch_name" placeholder="Branch Name"/>
                            </b-form-group>
                        </div>
                        <div class="d-flex flex-column px-3">
                            <b-form-group
                                label="GST Number"
                                class="mb-0"
                            >
                                <b-form-input type="text" v-model="create_branch_data.gst_number" placeholder="GST Number"/>
                            </b-form-group>
                        </div>
                        <div class="d-flex flex-column px-3">
                            <b-form-group
                                label="FSSAI Number"
                                class="mb-0"
                            >
                                <b-form-input type="text" v-model="create_branch_data.fssai_number" placeholder="FSSAI Number"/>
                            </b-form-group>
                        </div>
                        <div class="d-flex flex-column px-3">
                            <b-form-group
                                label="Email"
                                class="mb-0"
                            >
                                <b-form-input type="text" v-model="create_branch_data.email" placeholder="Email"/>
                            </b-form-group>
                        </div>
                        <div class="d-flex flex-column px-3">
                            <b-form-group
                                label="Password"
                                class="mb-0"
                            >
                                <b-form-input type="text" v-model="create_branch_data.password" placeholder="Password"/>
                            </b-form-group>
                        </div>
                        <div class="d-flex flex-row">
                            <div class="d-flex flex-column px-3">
                                <b-form-group
                                    label="Mobile"
                                    class="mb-0"
                                >
                                    <b-form-input type="text" v-model="create_branch_data.mobile" placeholder="Mobile"/>
                                </b-form-group>
                            </div>
                            <div class="d-flex flex-column px-3">
                                <b-form-group
                                    label="Alt Mobile"
                                    class="mb-0"
                                >
                                    <b-form-input type="text" v-model="create_branch_data.alt_mobile" placeholder="Alt Mobile"/>
                                </b-form-group>
                            </div>
                        </div>
                        <div class="d-flex flex-column px-3">
                            <b-form-group
                                label="Address - 1"
                                class="mb-0"
                            >
                                <b-form-input type="text" v-model="create_branch_data.add1" placeholder="Address - 1"/>
                            </b-form-group>
                        </div>
                        <div class="d-flex flex-column px-3">
                            <b-form-group
                                label="Address - 2"
                                class="mb-0"
                            >
                                <b-form-input type="text" v-model="create_branch_data.add2" placeholder="Address - 2"/>
                            </b-form-group>
                        </div>
                        <div class="d-flex flex-column px-3">
                            <b-form-group
                                label="Area"
                                class="mb-0"
                            >
                                <b-form-input type="text" v-model="create_branch_data.area" placeholder="Area"/>
                            </b-form-group>
                        </div>
                        <div class="d-flex flex-column px-3">
                            <b-form-group
                                label="Landmark"
                                class="mb-0"
                            >
                                <b-form-input type="text" v-model="create_branch_data.landmark" placeholder="Landmark"/>
                            </b-form-group>
                        </div>
                        <div class="d-flex flex-row">
                            <div class="d-flex flex-column px-3">
                                <b-form-group
                                    label="City"
                                    class="mb-0"
                                >
                                    <b-form-input type="text" v-model="create_branch_data.city" placeholder="City"/>
                                </b-form-group>
                            </div>
                            <div class="d-flex flex-column px-3">
                                <b-form-group
                                    label="State"
                                    class="mb-0"
                                >
                                    <b-form-input type="text" v-model="create_branch_data.state" placeholder="State"/>
                                </b-form-group>
                            </div>
                        </div>
                        <div class="d-flex flex-row">
                            <div class="d-flex flex-column px-3">
                                <b-form-group
                                    label="PIN"
                                    class="mb-0"
                                >
                                    <b-form-input type="text" v-model="create_branch_data.pin" placeholder="PIN"/>
                                </b-form-group>
                            </div>
                            <div class="d-flex flex-column px-3">
                                <b-form-group
                                    label="Country"
                                    class="mb-0"
                                >
                                    <b-form-input type="text" v-model="create_branch_data.country" placeholder="Country"/>
                                </b-form-group>
                            </div>
                        </div>
                        <div class="d-flex flex-row">
                            <div class="d-flex flex-column px-3">
                                <b-form-group
                                    label="Lattitude"
                                    class="mb-0"
                                >
                                    <b-form-input type="text" v-model="create_branch_data.lat" placeholder="Lattitude"/>
                                </b-form-group>
                            </div>
                            <div class="d-flex flex-column px-3">
                                <b-form-group
                                    label="Longitude"
                                    class="mb-0"
                                >
                                    <b-form-input type="text" v-model="create_branch_data.lng" placeholder="Longitude"/>
                                </b-form-group>
                            </div>
                        </div>
                        <div class="d-flex flex-row align-items-center">
                            <div class="d-flex flex-column px-3">
                                <b-form-group
                                    label="Branch Image"
                                    class="mb-0"
                                >
                                <b-form-file @input="changeImage($event)" v-model="create_branch_data.branch_image" class="mb-2"></b-form-file>
                                </b-form-group>
                            </div>
                            <div class="d-flex flex-column px-3" v-if="create_branch_data.branch_image_url">
                                <img style="width: 100px; border-radius: 16px;" :src="create_branch_data.branch_image_url" alt="Image">
                            </div>
                        </div>
                        <div class="d-flex flex-column px-3">
                            <b-form-group
                                label="Service Radius"
                                class="mb-0"
                            >
                                <b-form-input disabled type="number" @change="makeSelfDeliveryTimings(create_branch_data.service_radius)" v-model="create_branch_data.service_radius" placeholder="Service Radius"/>
                            </b-form-group>
                        </div>
                        <div class="d-flex flex-column px-3">
                            <b-form-group
                                label="Delivery Types"
                                class="mb-0"
                            >
                                <vSelect 
                                    multiple
                                    placeholder="Delivery Types"
                                    v-model="create_branch_data.vendor_delivery_types"
                                    :label="'type'"
                                    :options="delivery_types"
                                ></vSelect>
                            </b-form-group>
                        </div>
                        <div class="d-flex sub-category-form flex-column px-3" style="gap: 5px" v-if="create_branch_data.vendor_delivery_types.find(e => e.type == 'SELLER DELIVERY')  && create_branch_data.self_delivery_timings.length">
                            <div class="d-flex flex-row w-100" style="gap: 5px" v-for="(timing, timing_index) in create_branch_data.self_delivery_timings" :key="timing_index">
                                <span class="heading w-25" style="font-size: 16px; width: 25% !important; background: none; border: none; color: black;">
                                    {{ timing.km }} Km
                                </span>
                                <div class="d-flex flex-row w-75" style="gap: 5px" >
                                    <b-form-input class="" v-model="timing.price" placeholder="Price"></b-form-input>
                                    <b-form-input class="" v-model="timing.time" placeholder="Time"></b-form-input>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex sub-category-form flex-column px-3" style="gap: 5px" v-if="create_branch_data.vendor_delivery_types.find(e => e.type == 'SELLER DELIVERY')">
                            <span class="text-heading" style="font-size: 16px; width: max-content !important; background: none; border: none;">
                            Vendor Delivery Partner Details ({{ create_branch_data.seller_delivery_partners.length }})</span>
                            <div class="d-flex p-3 flex-column w-100" style="gap: 5px" v-for="(sel_del_partner, sel_del_partner_index) in create_branch_data.seller_delivery_partners" :key="sel_del_partner_index">
                                <div class="d-flex flex-row" style="gap: 5px;">
                                    <b-form-group
                                        label="First Name"
                                        class="mb-0"
                                    >
                                        <b-form-input type="text" v-model="create_branch_data.seller_delivery_partners[sel_del_partner_index].first_name" placeholder="First Name"/>
                                    </b-form-group>
                                    <b-form-group
                                        label="Last Name"
                                        class="mb-0"
                                    >
                                        <b-form-input type="text" v-model="create_branch_data.seller_delivery_partners[sel_del_partner_index].last_name" placeholder="Last Name"/>
                                    </b-form-group>
                                </div>
                                <div class="d-flex flex-row" style="gap: 5px;">
                                    <b-form-group
                                        label="Username"
                                        class="mb-0"
                                    >
                                        <b-form-input type="text" v-model="create_branch_data.seller_delivery_partners[sel_del_partner_index].username" placeholder="Username"/>
                                    </b-form-group>
                                    <b-form-group
                                        label="Password"
                                        class="mb-0"
                                    >
                                        <b-form-input type="text" v-model="create_branch_data.seller_delivery_partners[sel_del_partner_index].password" placeholder="Password"/>
                                    </b-form-group>
                                </div>
                                <div class="d-flex flex-row justify-content-center my-2" style="gap: 5px">
                                    <button class="button" @click.prevent="addAnother">Add Another</button>
                                    <button class="button" @click.prevent="removeDelPartner(sel_del_partner_index)" v-if="create_branch_data.seller_delivery_partners.length > 1">Remove This</button>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row text-center justify-content-center">
                            <div class="d-flex flex-row px-3">
                                <b-form-group
                                    label="Is Open"
                                    class="mb-0"
                                >
                                    <b-form-checkbox v-model="create_branch_data.is_open" size="lg" switch></b-form-checkbox>
                                </b-form-group>
                            </div>
                            <div class="d-flex flex-row px-3">
                                <b-form-group
                                    label="Verified"
                                    class="mb-0"
                                >
                                    <b-form-checkbox v-model="create_branch_data.verified" size="lg" switch></b-form-checkbox>
                                </b-form-group>
                            </div>
                            <div class="d-flex flex-row px-3">
                                <b-form-group
                                    label="Approved"
                                    class="mb-0"
                                >
                                    <b-form-checkbox size="lg" v-model="create_branch_data.approved" switch></b-form-checkbox>
                                </b-form-group>
                            </div>
                        </div>
                        <div class="d-flex justify-content-center ">
                            <button class="button" @click.prevent="!edit_id ? saveBranchDetails() : updateBranchDetails()">
                                {{ edit_id ? 'Update' : 'Create' }}
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import vSelect from 'vue-select';
export default {
    components: { vSelect },
    data() {
        return {
            store_list: [],
            branch_list: [],
            vendor_delivery_types: [],
            delivery_types: [],
            loader: false,
            selected_store_index: null,
            selected_store: null,
            open_form: false,
            edit_id: null,
            self_delivery_timing_template: {
                km: null,
                time: null,
                price: null
            },
            branch_product_list: [],
            create_branch_data: {
                branch_name: null,
                gst_number: null,
                fssai_number: null,
                email: null,
                password: null,
                mobile: null,
                alt_mobile: null,
                add1: null,
                add2: null,
                area: null,
                landmark: null,
                city: null,
                state: null,
                is_open: true,
                approved: true,
                verified: true,
                pin: null,
                country: null,
                lat: null,
                lng: null,
                branch_image: null,
                branch_image_url: null,
                vendor_delivery_types: [],
                service_radius: 5,
                self_delivery_timings: [],
                seller_delivery_partners: [
                    {
                        first_name: null,
                        last_name: null,
                        username: null,
                        password: null
                    }
                ]
            },
            selected_branch_index: null
        }
    },
    async mounted() { 
        this.loader = true
        await this.fetchStores()
        this.loader = false
    },
    methods: {
        async openBranchDetails(data, index) {
            this.loader = true
            if (this.selected_branch_index != null && index == this.selected_branch_index) {
                this.branch_product_list = []
                this.branch_list[this.selected_branch_index].collapse_active = false
                this.selected_branch_index = null
            } else if (this.selected_branch_index != null) {
                this.branch_list[this.selected_branch_index].collapse_active = false
                this.selected_branch_index = index 
                this.branch_list[this.selected_branch_index].collapse_active = true
                await this.fetchProductsForTheStores(this.selected_store.id, this.selected_store.vendor_id, data.id)
            } else {
                this.selected_branch_index = index 
                this.branch_list[this.selected_branch_index].collapse_active = true
                await this.fetchProductsForTheStores(this.selected_store.id, this.selected_store.vendor_id, data.id)
            }
            this.loader = false
        },
        async logout() {
            await this.$auth.logout()
            this.$router.push('/login')
        },
        async saveBranchDetails() {
            this.loader = true
            const keys = Object.keys(this.create_branch_data)
            const formData = new FormData()
            keys.forEach((key) => {
                if (key != 'branch_image_url') {
                    formData.append(key, Array.isArray(this.create_branch_data[key]) ? JSON.stringify(this.create_branch_data[key]) : this.create_branch_data[key])
                }
            })
            formData.append('vendor_id', this.selected_store.vendor_id)
            formData.append('store_id', this.selected_store.id)
            const response = await this.$axios.post("/create-new-branche", formData)
            this.$toast.show(response.data.message, {
                duration: 1500,
                position: 'top-right',
                keepOnHover: true,
                type: response.data.status
            })
            await this.fetchBranches()
            this.closeForm()
            this.loader = false
        },
        addAnother() {
            this.create_branch_data.seller_delivery_partners.push({
                first_name: null,
                last_name: null,
                username: null,
                password: null
            })
        },
        removeDelPartner(index) {
            this.create_branch_data.seller_delivery_partners.splice(index, 1)
        },
        makeSelfDeliveryTimings(num) {
            const array =  Array.from(Array(parseInt(num)).keys()).map(e => e+1)
            this.create_branch_data.self_delivery_timings = array.map(e => {
                return {
                    ...this.self_delivery_timing_template,
                    km: e
                }
            })
        },
        closeForm() {
            this.open_form = false
            this.create_branch_data = {
                branch_name: null,
                gst_number: null,
                fssai_number: null,
                email: null,
                password: null,
                mobile: null,
                alt_mobile: null,
                add1: null,
                add2: null,
                area: null,
                landmark: null,
                city: null,
                state: null,
                is_open: true,
                approved: true,
                verified: true,
                pin: null,
                country: null,
                lat: null,
                lng: null,
                branch_image: null,
                branch_image_url: null,
                vendor_delivery_types: [],
                service_radius: 5,
                self_delivery_timings: [],
                seller_delivery_partners: [
                    {
                        first_name: null,
                        last_name: null,
                        username: null,
                        password: null
                    }
                ]
            }
        },
        async changeImage(event) { 
            this.create_branch_data.branch_image_url = URL.createObjectURL(event)
        },
        async openCreateForm() {
            this.loader = true
            this.open_form = true
            await this.fetchDeliveryTypes()
            await this.fetchDeliveryTypesForVendor()
            this.makeSelfDeliveryTimings(5)
            this.loader = false
        },
        async showStoreForIndex(store_index) { 
            this.loader = true
            this.selected_store_index = store_index
            this.selected_store = this.store_list[this.selected_store_index]
            await this.fetchBranches()
            await this.fetchDeliveryTypesForVendor()
            this.closeForm()
            this.loader = false
        },
        async fetchStores() {
            try {
                const response = await this.$axios.get('/fetch-all-stores')
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.store_list = response.data.stores
            } catch (error) {
                console.log(error);
            }
        },
        async fetchBranches() {
            try {
                let api_path = `/fetch-branches?vendor_id=${this.selected_store?.vendor?.id}&store_id=${this.selected_store.id}`
                const response = await this.$axios.get(api_path)
                if (response.data.code == 401) {
                    await this.logout()
                }
                if (response.data.code == 200) {
                    this.branch_list = response.data.branches.map(e => {
                        return {
                            ...e,
                            collapse_active: false,
                        }
                    })
                } else {
                    this.branch_list = []
                }
            } catch (error) {
                console.log(error);
                this.branch_list = []
            }
        },
        async fetchDeliveryTypes() {
            try {
                const response = await this.$axios.get('/get-delivery-types')
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.delivery_types = response.data.delivery_types
            } catch (error) {
                console.log(error);
            }
        },
        async fetchDeliveryTypesForVendor() {
            try {
                const response = await this.$axios.get(`/get-vendor-delivery-types?vendor_id=${this.selected_store?.vendor?.id}`)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.vendor_delivery_types = response.data.delivery_types
                this.create_branch_data.vendor_delivery_types = this.vendor_delivery_types
            } catch (error) {
                console.log(error);
            }
        },
        async fetchProductsForTheStores(store, vendor, branch) {
            let path = `/fetch-all-products-for-branch?vendor_id=${vendor}&store_id=${store}&branch_id=${branch}`
            const response = await this.$axios.get(path)
            this.branch_product_list = response.data.products.map(e => {
                return {
                    ...e,
                    active: Boolean(e.active)
                }
            })
        }
    }
}
</script>