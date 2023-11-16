<template>
    <b-sidebar 
    id="product_add_form" 
    backdrop 
    :visible="visible" 
    title="Sidebar" 
    right 
    shadow
    backdrop-variant="dark"
    no-close-on-backdrop
    no-header
    lazy
    no-footer
    width="500px"
    >
        <div v-if="loader" class="loader">
            <LoaderComp />
        </div>
        <div class="container d-flex flex-column" v-else>
            <div class="d-flex flex-row align-items-center justify-content-between p-3">
                <span class="sidebar-heading" style="padding-left: 0px !important;"> {{ title }} </span>
                <i @click.prevent="resetForm" style="cursor: pointer;" class="fa fa-times text-danger"></i>
            </div>
            <div class="d-flex flex-row w-100">
                <div class="d-flex flex-column align-items-left w-100">
                    <div class="w-100">
                        <label class="input-label">Vendor: </label>
                    </div>
                    <div class="w-100">
                        <b-form-select
                            style="width: 100% !important;"
                            value-field="id"
                            text-field="fullname"
                            v-model="selected_vendor"
                            :options="vendor_list">
                        </b-form-select>
                    </div>
                </div>
            </div>
            <template v-if="innerLoader">
                <div class="loader">
                    <LoaderComp />
                </div>
            </template>
            <template v-if="selected_vendor && !innerLoader">
                <div class="d-flex flex-row w-100">
                    <div class="d-flex flex-column align-items-left w-100">
                        <div class="w-100">
                            <label class="input-label">Category: </label>
                        </div>
                        <div class="w-100">
                            <b-form-select
                                style="width: 100% !important;"
                                value-field="id"
                                text-field="category_name"
                                v-model="selected_category"
                                :options="category_list">
                            </b-form-select>
                        </div>
                    </div>
                </div>
                <template 
                    v-if="selected_category && ['Food', 'Food Court'].includes(category_list.find(e => e.id == selected_category).category_name)"
                >
                    <div class="d-flex flex-row w-100">
                        <div class="d-flex flex-row align-items-center w-100">
                            <div class="w-50">
                                <label class="input-label">Food Type: </label>
                            </div>
                            <div class="w-50 pt-3 d-flex flex-row-reverse">
                                <b-form-group
                                v-slot="{ ariaDescribedby }"
                                >
                                    <b-form-radio-group
                                        id="btn-radios-2"
                                        v-model="selected_food_type"
                                        :options="food_types"
                                        :aria-describedby="ariaDescribedby"
                                        :button-variant="selected_food_type == 'VEG' ? 'outline-success' : 'outline-danger'"
                                        size="sm"
                                        name="radio-btn-outline"
                                        buttons
                                    ></b-form-radio-group>
                                </b-form-group>

                            </div>
                        </div>
                    </div>
                    <div class="d-flex flex-row w-100">
                        <div class="d-flex flex-column align-items-left w-100">
                            <div class="w-100">
                                <label class="input-label">Product Title: </label>
                            </div>
                            <div class="w-100">
                                <b-form-input v-model="foodData.title" placeholder="Product Title"></b-form-input>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex flex-row w-100">
                        <div class="d-flex flex-column align-items-left w-100">
                            <div class="w-100">
                                <label class="input-label">Product Description: </label>
                            </div>
                            <div class="w-100">
                                <b-form-textarea
                                    id="textarea"
                                    v-model="foodData.description"
                                    placeholder="Product Description.."
                                    rows="3"
                                    max-rows="6"
                                ></b-form-textarea>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex flex-row w-100">
                        <div class="d-flex flex-column align-items-left w-100">
                            <div class="w-100">
                                <label class="input-label">Product Timings: </label>
                            </div>
                            <div class="w-100 d-flex flex-row align-items-center" style="gap: 15px !important;">
                                <b-form-checkbox class="w30" v-model="foodData.hasTime" switch><span class="text-heading" style="margin-left: 0px !important;">Has Time</span></b-form-checkbox>
                                <b-form-timepicker class="w30" v-model="foodData.openTime" placeholder="time" locale="en"></b-form-timepicker>
                                <b-form-timepicker class="w30" v-model="foodData.closeTime" placeholder="time" locale="en"></b-form-timepicker>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex flex-row w-100">
                        <div class="d-flex flex-column align-items-left w-100">
                            <div class="w-100">
                                <label class="input-label">Product Images: </label>
                            </div>
                            <div class="w-100">
                                <input @input="handleFile($event)" accept="image/*" type="file" id="files" name="files" multiple />
                            </div>
                            <div class="d-flex flex-row"
                                v-if="title == 'Edit Product'"
                                style="
                                    padding: 10px;
                                    overflow-x: scroll !important;
                                    width: 100% !important;
                                    object-fit: cover;
                                "
                            >
                                <div class="d-flex flex-row"
                                    style="
                                        gap: 10px;
                                    "
                                >
                                    <img style="height: 100px !important; width: 100px !important; border-radius: 16px;" :src="image.image_url" v-for="(image, image_index) in selected_images" :key="image_index" alt="Image">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card d-flex flex-column p-3 mt-3" style="border-radius: 16px;">
                        <div class="d-flex flex-row w-100">
                            <div class="d-flex flex-column align-items-left w-100">
                                <div class="w-100">
                                    <label class="input-label">Price (₹): </label>
                                </div>
                                <div class="w-100">
                                    <b-form-input v-model="foodData.price" placeholder="Price"></b-form-input>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row w-100">
                            <div class="d-flex flex-column align-items-left w-100">
                                <div class="w-100">
                                    <label class="input-label">Compare Price (₹): </label>
                                </div>
                                <div class="w-100">
                                    <b-form-input placeholder="Compare Price" v-model="foodData.compare_price"></b-form-input>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row w-100">
                            <div class="d-flex flex-column align-items-left w-100">
                                <div class="w-100">
                                    <label class="input-label">GST (%): </label>
                                </div>
                                <div class="w-100">
                                    <b-form-input placeholder="GST" v-model="foodData.gst"></b-form-input>
                                </div>
                            </div>
                        </div>
                    </div>
                </template>
            </template>
            <div v-if="selected_vendor && !innerLoader" class="d-flex flex-row justify-content-center p-3 w-100">
                <button class="button" @click.prevent="SaveData">
                    <i class="fa fa-save mr-2"></i> Save
                </button>
            </div>
        </div>
    </b-sidebar>
</template>

<script>
import Joi from 'joi'
import LoaderComp from './loader.vue';
export default {
    components: {
        LoaderComp
    },
    props: [
        'edit_data',
        'visible',
        'title',
        'product_data'
    ],
    data() { 
        return {
            update_id: null,
            innerLoader: false,
            selected_images: [],
            loader: false,
            category_list: [],
            selected_category: null,
            vendor_list: [],
            files: [],
            image_url_list: [],
            selected_vendor: null,
            food_types: ['VEG', 'NON-VEG'],
            selected_food_type: 'VEG',
            foodData: {
                title: null,
                description: null,
                files: null,
                price: null,
                hasTime: false,
                openTime: null,
                closeTime: null,
                compare_price: null,
                gst: null,
            },
            created_product_id: null,
        }
    },
    watch: {
        async selected_vendor(val) {
            if (val) { 
                this.fetchCategories()
            }
        },
        async visible(val) {
            this.loader = true
            if (val == true) {
                await this.fetchApprovedVendors()
                if (this.edit_data) {
                    await this.placeProductData(this.product_data)
                }
            }
            this.loader = false
        }
    },
    methods: {
        async resetForm() {
            this.category_list = []
            this.selected_images = []
            this.selected_category = null
            this.vendor_list = []
            this.selected_vendor = null
            this.files = []
            this.food_types = ['VEG', 'NON-VEG']
            this.selected_food_type = 'VEG'
            this.update_id = null
            this.foodData = {
                title: null,
                description: null,
                files: null,
                price: null,
                compare_price: null,
                gst: null,
            }
            await this.emitClose()
        },
        async emitClose() {
            this.$emit('closeSidebar')
        },
        async fetchApprovedVendors() {
            try {
                let query = `/approved-vendor`
                const response = await this.$axios.get(query)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.vendor_list = response.data.vendors
                this.vendor_list.unshift({
                    id: null,
                    fullname: 'Select a vendor'
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
                this.category_list = response.data.product_types
                this.category_list.unshift({
                    id: null,
                    category_name: 'Select a category'
                })
                this.innerLoader = false
            } catch (error) {
                console.log(error);
            }
        },
        async fetchSubCategories() {
            try {
                this.innerLoader = true
                const path = `/get-categories?vendor_id=${this.selected_vendor}`
                const response = await this.$axios.get(path)
                // console.log(response);
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.category_list = response.data.categories
                // this.category_list.unshift({
                //     id: null,
                //     category_name: 'Select a category'
                // })
                this.innerLoader = false
            } catch (error) {
                console.log(error);
            }
        },
        async SaveData() {
            this.loader = true
            try {
                if (!this.selected_vendor) {
                    this.$toast.show('Please select a vendor.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                    return
                }
                if (!this.selected_category) {
                    this.$toast.show('Please select a category.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                    return
                }
                if (
                    this.selected_category &&
                    ['Food', 'Food Court'].includes(this.category_list.find(e => e.id == this.selected_category).category_name) &&
                    !this.selected_food_type
                ) {
                    this.$toast.show('Please select a food type.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                    return
                }
                if (['Food', 'Food Court'].includes(this.category_list.find(e => e.id == this.selected_category).category_name)) {
                    await this.saveFoodOrFoodCour()
                } else {

                }
            } catch (error) {
                console.log(error);
            }
            this.loader = false
        },
        async check_food_data(data, type = 'ADD') {
            try {
                if (type == 'ADD') {
                    const foodModel = Joi.object({
                        vendor_id: Joi.number().integer().required(),
                        name: Joi.string().max(255).required(),
                        description: Joi.string().max(1000).required(),
                        total_price: Joi.number().required(),
                        compare_price: Joi.number().required(),
                        gst: Joi.number().required(),
                        food_type: Joi.string().allow(null),
                        tags: Joi.string().allow(null).allow(''),
                        free_delivery: Joi.boolean().required().default(false),
                        free_delivery_if_more: Joi.number().allow(null).allow(0),
                        category: Joi.object({
                            id: Joi.number().integer().required(),
                            category_name: Joi.string().required(),
                            table_name: Joi.string().required()
                        }).required(),
                        sub_categories: Joi.array().items(Joi.object({
                            id: Joi.number().integer().required(),
                            name: Joi.string().required()
                        })).allow(null).empty(Joi.array().max(0)),
                        size: Joi.string().max(255).required(),
                        has_time: Joi.boolean().default(false).allow(null),
                        open_time: Joi.string().allow(null),
                        close_time: Joi.string().allow(null),
                        // is_veg: Joi.boolean().default(true).required(),
                        available: Joi.boolean().default(true).required(),
                    })
                    const result = await foodModel.validateAsync(data)
                    return result
                } else {
                    const updatefoodModel = Joi.object({
                        product_id: Joi.number().integer().required(),
                        vendor_id: Joi.number().integer().required(),
                        name: Joi.string().max(255).required(),
                        description: Joi.string().max(1000).required(),
                        total_price: Joi.number().required(),
                        compare_price: Joi.number().required(),
                        gst: Joi.number().required(),
                        food_type: Joi.string().allow(null),
                        tags: Joi.string().allow(null).allow(''),
                        free_delivery: Joi.boolean().required().default(false),
                        free_delivery_if_more: Joi.number().allow(null).allow(0),
                        category: Joi.object({
                            id: Joi.number().integer().required(),
                            category_name: Joi.string().required(),
                            table_name: Joi.string().required()
                        }).required(),
                        sub_categories: Joi.array().items(Joi.object({
                            id: Joi.number().integer().required(),
                            name: Joi.string().required()
                        })).allow(null).empty(Joi.array().max(0)),
                        size: Joi.string().max(255).required(),
                        has_time: Joi.boolean().default(false).allow(null),
                        open_time: Joi.string().allow(null),
                        close_time: Joi.string().allow(null),
                        // is_veg: Joi.boolean().default(true).required(),
                        available: Joi.boolean().default(true).required(),
                    })
                    const result = await updatefoodModel.validateAsync(data)
                    return result
                }
            } catch (error) {
                this.$toast.show(error.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                return false
            }
        },
        async saveFoodOrFoodCour() {
            this.loader = true
            try {
                const category = this.category_list.find(e => e.id == this.selected_category)
                delete category.image
                const addData = this.update_id ? {
                    product_id: this.update_id,
                    vendor_id: this.selected_vendor,
                    name: this.foodData.title,
                    description: this.foodData.description,
                    total_price: this.foodData.price,
                    compare_price: this.foodData.compare_price,
                    gst: this.foodData.gst,
                    food_type: this.selected_food_type,
                    category: category,
                    size: 'l',
                    available: true,
                    has_time: this.foodData.hasTime,
                    open_time: this.foodData.openTime,
                    close_time: this.foodData.closeTime,
                    free_delivery: false
                } : {
                    vendor_id: this.selected_vendor,
                    name: this.foodData.title,
                    description: this.foodData.description,
                    total_price: this.foodData.price,
                    compare_price: this.foodData.compare_price,
                    gst: this.foodData.gst,
                    food_type: this.selected_food_type,
                    category: category,
                    size: 'l',
                    available: true,
                    has_time: this.foodData.hasTime,
                    open_time: this.foodData.openTime,
                    close_time: this.foodData.closeTime,
                    free_delivery: false
                }
                const result = await this.check_food_data(addData, this.update_id ? 'EDIT' : 'ADD')
                if (!result) return
                const response = await this.$axios({
                    method: 'post',
                    url: this.update_id ? '/update-food-without-images' : `/add-food-without-images`,
                    data: result
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
                this.created_product_id = response.data.created_product
                await this.saveImage()
                this.resetForm()
            } catch (error) {
                console.log(error);
            }
            this.loader = false
        },
        handleFile(event) {
            for (const file of event.target.files) {
                this.files.push(file)
                this.image_url_list.push(URL.createObjectURL(file))
            }
        },
        async saveImage() {
            try {
                const category = this.category_list.find(e => e.id == this.selected_category)
                const new_form = new FormData()
                for (let index = 0; index < this.files.length; index++) {
                    new_form.append(`file${index + 1}`, this.files[index])
                }
                new_form.append('product_id', this.created_product_id.id)
                new_form.append('product_category_name', category.category_name)
                new_form.append('images_count', this.files.length)
                new_form.append('active', true)
                const response = await this.$axios({
                    method: 'post',
                    url: `/add-product-images`,
                    data: new_form
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
                if (response.data.code == 200) {
                    await this.resetForm()
                }
            } catch (error) {
                console.log(error);
            }
        },
        async placeProductData(data) {
            this.update_id = data.id
            this.selected_vendor = data.vendor_id
            this.selected_category = data.category_id
            this.selected_food_type = data.food_type
            this.foodData.title = data.name
            this.foodData.description = data.description
            this.foodData.compare_price = data.compare_price
            this.foodData.price = data.price
            this.foodData.gst = data.gst
            this.foodData.hasTime = Boolean(data.has_time)
            this.foodData.openTime = data.open_time
            this.foodData.closeTime = data.close_time
            this.selected_images = data.images_of_products
        },
        async logout() {
            await this.$auth.logout()
            this.$router.push('/login')
        },
    },
}
</script>

<style>
#product_add_form {
    border-bottom-left-radius: 24px;
    border-top-left-radius: 24px;
    padding: 16px;
}
</style>