<template>
    <div class="customer-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="tabs-content">
            <div class="d-flex flex-row w-100" style="gap: 30px">
                <div class="d-flex flex-column w50">
                    <div class="d-flex flex-row justify-content-between align-items-center">
                        <span class="text-heading fontSize25" >Coupons</span>
                        <div class="d-flex flex-row-reverse gap10">
                            <button @click.prevent="openCouponAddForm('vendor')" v-b-tooltip.hover title="Add Vendor Coupons" class="button" ><i class="fa fa-plus mr-2"></i>Vendor<i class='bx bxs-coupon ml-2'></i></button>
                            <button @click.prevent="openCouponAddForm('admin')" v-b-tooltip.hover title="Add Admin Coupons" class="button" ><i class="fa fa-plus mr-2"></i>Admin<i class='bx bxs-coupon ml-2'></i></button>
                            <button @click.prevent="fetchCoupons" class="button"><i class="fa fa-refresh"></i></button>
                        </div>
                    </div>
                    <div class="d-flex flex-column py-3 gap16">
                        <div class="sub-category-form text-center" v-if="coupons_list.length == 0">
                            <span class="text-heading fontSize20">No Coupons Found.</span>
                        </div>
                        <div class="sub-category-form border d-flex flex-column" v-else  v-for="(coupon, coupon_index) in coupons_list" :key="coupon_index">
                            <div class="d-flex justify-content-between">
                                <span style="padding-left: 0px;" class="text-heading fontSize25 align-items-center d-flex"><i class="bx bxs-coupon mr-2"></i>{{ coupon.code }}</span>
                                <button class="button" @click.prevent="openEdit(coupon)"><i class="fa fa-pencil mr-2"></i> Edit</button>
                            </div>
                            <div class="d-flex flex-row justify-content-center">
                                <span style="padding-left: 0px;" class="align-self-stretch text-heading"> <strong><strong>Valid till:</strong></strong> {{ new Date(coupon.valid_till).toLocaleDateString() }}</span>
                                <span style="padding-left: 0px;" class="align-self-stretch text-heading"><strong><strong>Discount (%):</strong></strong> {{ coupon.discount }} %</span>
                                <span style="padding-left: 0px;" class="align-self-stretch text-heading"><strong><strong>Max Discount (₹):</strong></strong> ₹ {{ coupon.max_discount }}</span>
                            </div>
                            <div class="d-flex flex-row justify-content-center">
                                <span style="padding-left: 0px;" class="align-self-stretch text-heading"><strong><strong>Use Per User:</strong></strong> {{ coupon.use_per_user }}</span>
                                <div class="d-flex flex-row align-items-center px-2 mx-2">
                                    <span style="padding-left: 0px;" class="align-self-stretch text-heading"><strong><strong>Status</strong></strong></span>
                                    <b-form-checkbox @change="enableDisable(coupon, coupon.status)" v-model="coupon.status" switch></b-form-checkbox>
                                </div>
                                <span style="padding-left: 0px;" class="align-self-stretch text-heading"><strong><strong>Type:</strong></strong> {{ coupon.vendor_id ? 'VENDOR' : 'ADMIN' }}</span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="d-flex flex-column w50">
                    <div class="sub-category-form" v-if="admin_coupon">
                        <div class="d-flex flex-row justify-content-between align-items-center">
                            <span class="text-heading fontSize25" >{{title}}</span>
                            <i @click.prevent="closeForm" class="fa fa-close fontSize25 text-danger cursor-pointer"></i>
                        </div>
                        <div class="d-flex flex-column pt-3">
                            <div class="d-flex flex-column">
                                <span class="text-heading" style="padding-left: 0px;">Coupon Code</span>
                                <b-form-input v-model="admin_coupon_data.code" placeholder="Coupon Code"></b-form-input>
                            </div>
                            <div class="d-flex flex-column">
                                <span class="text-heading" style="padding-left: 0px;">Description</span>
                                <b-form-textarea
                                    id="textarea" v-model="admin_coupon_data.description"
                                    placeholder="Description"
                                    rows="3"
                                    max-rows="6"
                                   
                                ></b-form-textarea>
                            </div>
                            <div class="d-flex flex-row gap16">
                                <div class="d-flex flex-column w50">
                                    <span class="text-heading" style="padding-left: 0px;">Discount (%)</span>
                                    <b-form-input v-model="admin_coupon_data.discount" placeholder="Discount (%)"></b-form-input>
                                </div>
                                <div class="d-flex flex-column w50">
                                    <span class="text-heading" style="padding-left: 0px;">Max Amount Discount</span>
                                    <b-form-input v-model="admin_coupon_data.max_amount_discount" placeholder="Max Amount Discount"></b-form-input>
                                </div>
                            </div>
                            <div class="d-flex flex-row gap16">
                                <div class="d-flex flex-column w50">
                                    <span class="text-heading" style="padding-left: 0px;">Max use per user</span>
                                    <b-form-input v-model="admin_coupon_data.max_use_per_user" placeholder="Max use per user"></b-form-input>
                                </div>
                                <div class="d-flex flex-column w50">
                                    <span class="text-heading" style="padding-left: 0px;">Valid Till Date</span>
                                    <input v-model="admin_coupon_data.valid_till" type="date" class="form-control">
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row align-items-center justify-content-center mt-4">
                            <button class="button" @click.prevent="saveCouponForAdmin"><i class="fa fa-save mr-2"></i>Save</button>
                        </div>
                    </div>
                    <div class="sub-category-form" v-if="vendor_coupon">
                        <div class="d-flex flex-row justify-content-between align-items-center">
                            <span class="text-heading fontSize25" >{{title}}</span>
                            <i @click.prevent="closeForm" class="fa fa-close fontSize25 text-danger cursor-pointer"></i>
                        </div>
                        <div class="d-flex flex-column pt-3">
                            <div class="d-flex flex-column">
                                <span class="text-heading" style="padding-left: 0px;">Vendor</span>
                                <b-form-select class="mb-2" @change="fetchCategories" :options="vendor_list" v-model="selected_vendor"></b-form-select>
                            </div>
                            <div v-if="selected_vendor">
                                <div class="d-flex flex-column">
                                    <span class="text-heading" style="padding-left: 0px;">Product Type</span>
                                    <b-form-select class="mb-2" :options="category_list" v-model="selected_category"></b-form-select>
                                </div>
                                <div class="d-flex flex-column">
                                    <span class="text-heading" style="padding-left: 0px;">Coupon Code</span>
                                    <b-form-input v-model="vendor_coupon_data.code" placeholder="Coupon Code"></b-form-input>
                                </div>
                                <div class="d-flex flex-column">
                                    <span class="text-heading" style="padding-left: 0px;">Description</span>
                                    <b-form-textarea
                                        id="textarea" v-model="vendor_coupon_data.description"
                                        placeholder="Description"
                                        rows="3"
                                        max-rows="6"
                                    
                                    ></b-form-textarea>
                                </div>
                                <div class="d-flex flex-row gap16">
                                    <div class="d-flex flex-column w50">
                                        <span class="text-heading" style="padding-left: 0px;">Discount (%)</span>
                                        <b-form-input v-model="vendor_coupon_data.discount" placeholder="Discount (%)"></b-form-input>
                                    </div>
                                    <div class="d-flex flex-column w50">
                                        <span class="text-heading" style="padding-left: 0px;">Max Amount Discount</span>
                                        <b-form-input v-model="vendor_coupon_data.max_amount_discount" placeholder="Max Amount Discount"></b-form-input>
                                    </div>
                                </div>
                                <div class="d-flex flex-row gap16">
                                    <div class="d-flex flex-column w50">
                                        <span class="text-heading" style="padding-left: 0px;">Max use per user</span>
                                        <b-form-input v-model="vendor_coupon_data.max_use_per_user" placeholder="Max use per user"></b-form-input>
                                    </div>
                                    <div class="d-flex flex-column w50">
                                        <span class="text-heading" style="padding-left: 0px;">Valid Till Date</span>
                                        <input v-model="vendor_coupon_data.valid_till" type="date" class="form-control">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row align-items-center justify-content-center mt-4">
                            <button class="button" @click.prevent="saveCouponForVendor"><i class="fa fa-save mr-2"></i>Save</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import Loader from './loader.vue';
export default {
    data() {
        return {
            loader: false,
            coupons_list: [],
            temp_coupon_list: [],
            title: null,
            admin_coupon: false,
            edit_id: null,
            admin_coupon_data: {
                code: null,
                description: null,
                discount: null,
                max_amount_discount: null,
                max_use_per_user: 1,
                valid_till: this.formatDate(new Date()),
            },
            vendor_coupon: false,
            vendor_coupon_data: {
                code: null,
                description: null,
                discount: null,
                max_amount_discount: null,
                max_use_per_user: 1,
                valid_till: this.formatDate(new Date()),
            },
            vendor_list: [],
            selected_vendor: null,
            category_list: [],
            selected_category: null,
        }
    },
    async mounted() {
        await this.fetchCoupons()
    },
    props: ['searchText'],
    watch: {
        searchText(val) {
            clearTimeout(this.timer)
            this.timer = setTimeout(async () => {
                this.loader = true
                await this.fetchCoupons()
                this.loader = false
            }, 300);
        },
    },
    methods: {
        formatDate(today) {
            const year = today.getFullYear();
            const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are 0-indexed
            const day = String(today.getDate()).padStart(2, '0');
            const formattedDate = `${year}-${month}-${day}`;
            return formattedDate
        },
        async openEdit(coupon) {
            this.edit_id = coupon.id
            if (coupon.vendor_id) {
                this.title = 'Update Vendor Coupon'
                await this.fetchApprovedVendors()
                this.selected_vendor = coupon.vendor_id
                await this.fetchCategories()
                this.selected_category = coupon.category_id
                this.vendor_coupon_data = {
                    code: coupon.code,
                    description: coupon.description,
                    discount: coupon.discount,
                    max_amount_discount: coupon.max_discount,
                    max_use_per_user: coupon.use_per_user,
                    valid_till: this.formatDate(new Date(coupon.valid_till)),
                }
                this.vendor_coupon = true
                this.admin_coupon = false
            } else {
                this.admin_coupon_data = {
                    code: coupon.code,
                    description: coupon.description,
                    discount: coupon.discount,
                    max_amount_discount: coupon.max_discount,
                    max_use_per_user: coupon.use_per_user,
                    valid_till: this.formatDate(new Date(coupon.valid_till)),
                }
                this.title = 'Update Admin Coupon'
                this.vendor_coupon = false
                this.admin_coupon = true
            }
        },
        async enableDisable(data, status) { 
            this.loader = true
            try {
                const response = await this.$axios({
                    method: 'post',
                    url: '/enable-disable-coupon-vendor-admin',
                    data: {
                        id: data.id,
                        status
                    }
                })
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                await this.fetchCoupons()
                this.closeForm()
            } catch (error) {
                console.log(error);
            }
            this.loader = false
        },
        async saveCouponForVendor() {
            this.loader = true
            try {
                const response = await this.$axios({
                    method: 'post',
                    url: this.edit_id ? '/update-coupon-vendor-admin' : '/add-coupon-vendor-admin',
                    data: this.edit_id ? {
                        id: this.edit_id,
                        vendor_id: this.selected_vendor,
                        category_id: this.selected_category,
                        ...this.vendor_coupon_data,
                        status: true
                    } : {
                        vendor_id: this.selected_vendor,
                        category_id: this.selected_category,
                        ...this.vendor_coupon_data,
                        status: true
                    }
                })
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                await this.fetchCoupons()
                this.closeForm()
            } catch (error) {
                console.log(error);
            }
            this.loader = false
        },
        async saveCouponForAdmin() {
            this.loader = true
            try {
                const response = await this.$axios({
                    method: 'post',
                    url: this.edit_id ? '/update-coupon-vendor-admin' : '/add-coupon-vendor-admin',
                    data: this.edit_id ? {
                        id: this.edit_id,
                        ...this.admin_coupon_data,
                        status: true
                    } : {
                        ...this.admin_coupon_data,
                        status: true
                    }
                })
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                await this.fetchCoupons()
                this.closeForm()
            } catch (error) {
                console.log(error);
            }
            this.loader = false
        },
        closeForm() { 
            this.admin_coupon = false
            this.vendor_coupon = false
            this.title = null
            this.admin_coupon_data = {
                code: null,
                description: null,
                discount: null,
                max_amount_discount: null,
                max_use_per_user: 1,
                valid_till: this.formatDate(new Date()),
            }
            this.vendor_coupon_data = {
                code: null,
                descripition: null,
                discount: null,
                total_amount: null,
                final_amount: null,
                status: null,
                user_id: null,
                products: [
                    {
                        product_id: null,
                        category_id: null
                    }
                ],
            }
        },
        async fetchCoupons() {
            this.loader = true
            try {
                let path = '/get-coupons'
                if (this.searchText) {
                    path = `${path}?q=${this.searchText}`
                }
                const response = await this.$axios.get(path)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.coupons_list = response.data.coupons
                this.$emit('reloadDashboard')
            } catch (error) {
              console.log(error);  
            }
            this.loader = false
        },
        async openCouponAddForm(type) { 
            switch (type) {
                case 'admin':
                    this.title = 'Add Admin Coupon'
                    this.admin_coupon = true
                    this.vendor_coupon = false
                    break;
                case 'vendor':
                    await this.fetchApprovedVendors()
                    this.title = 'Add Vendor Coupon'
                    this.admin_coupon = false
                    this.vendor_coupon = true
                    break;
            }
        },
        async fetchApprovedVendors() {
            try {
                let query = `/approved-vendor`
                const response = await this.$axios.get(query)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.vendor_list = response.data.vendors.map(e => {
                    console.log(e);
                    return {
                        value: e.id,
                        text: `${e.fullname} (${e.store.name})`
                    }
                })
                this.vendor_list.unshift({
                    value: null,
                    text: 'Select a vendor'
                })
            } catch (error) {
                console.log(error);
            }
        },
        async fetchCategories() {
            try {
                this.innerLoader = true
                const path = `/get-categories?vendor_id=${this.selected_vendor}`
                const response = await this.$axios.get(path)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.category_list = response.data.product_types.map(e => {
                    return {
                        value: e.id,
                        text: e.category_name
                    }
                })
                this.category_list.unshift({
                    value: null,
                    text: 'Select a category'
                })
                this.innerLoader = false
            } catch (error) {
                console.log(error);
            }
        },
        async logout() {
            localStorage.removeItem('token')
            // localStorage.removeItem('refreshToken')
            this.$router.push('/login')
        },
    }
}
</script>