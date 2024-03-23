<template>
    <b-sidebar id="product_add_form" backdrop :visible="visible" title="Sidebar" right shadow backdrop-variant="dark"
        no-close-on-backdrop no-header lazy no-footer width="500px">
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
                        <b-form-select style="width: 100% !important;" value-field="id" text-field="fullname"
                            v-model="selected_vendor" :options="vendor_list">
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
                            <b-form-select style="width: 100% !important;" value-field="id" text-field="category_name"
                                v-model="selected_category" :options="category_list">
                            </b-form-select>
                        </div>
                    </div>
                </div>
                <div class="d-flex flex-row w-100" v-if="selected_category && !innerLoader">
                    <div class="d-flex flex-column align-items-left w-100">
                        <div class="w-100">
                            <label class="input-label">Sub-Category: </label>
                        </div>
                        <div class="w-100">
                            <vSelect style="width: 100% !important;" label="name" multiple v-model="selected_sub_category"
                                :options="sub_category_list">
                            </vSelect>
                        </div>
                    </div>
                </div>
                
                <template 
                    v-if="selected_category && !['Food', 'Food Court'].includes(category_list.find(e => e.id == selected_category).category_name)"
                >
                    <div class="d-flex flex-row w-100">
                        <div class="d-flex flex-column align-items-left w-100">
                            <div class="w-100">
                                <label class="input-label">Product Title: </label>
                            </div>
                            <div class="w-100">
                                <b-form-input v-model="otherProductData.title" placeholder="Product Title"></b-form-input>
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
                                    v-model="otherProductData.description"
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
                                    <div class="d-flex flex-column gap8" style="height: max-content; width: max-content;" v-for="(image, image_index) in selected_images" :key="image_index">
                                        <img style="height: 100px !important; width: 100px !important; border-radius: 16px;" :src="image.image_url" alt="Image">
                                        <button @click.prevent="deleteImage(image, image_index)" class="w100 btn btn-danger"><i class="fa fa-trash mr-2"></i>Delete</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card d-flex flex-column p-3 mt-3" style="border-radius: 16px;">
                        <template v-if="attributes_list.length">
                            <div class="d-flex flex-column align-items-left w-100">
                                <div class="w-100">
                                    <label class="input-label">Select attributes: </label>
                                </div>
                                <div class="w-100">
                                    <vSelect style="width: 100% !important;" label="attribute_name" multiple
                                        v-model="selected_attributes" :options="attributes_list">
                                    </vSelect>
                                </div>
                            </div>
                            <div class="d-flex flex-column align-items-left w-100" v-if="selected_attributes.length">
                                <div class="w-100">
                                    <label class="input-label">Attributes: </label>
                                </div>
                                <div class="w-100" v-for="(attribute, attr_index) in selected_attributes">
                                    <div class="w-100 selected_attribute_container">
                                        <div class="d-flex selected_attribute"
                                        v-for="(selected_data, selected_data_index) in attribute.attributes">
                                        <span>{{ selected_data }}</span>
                                        <i class="fa fa-times attribute_cross_button" @click.prevent="() => {
                                            attribute.attributes.splice(selected_data_index, 1)
                                        }"></i>
                                        </div>
                                    </div>
                                    <b-form-input :placeholder="attribute.attribute_name" v-model="attribute.attribute"
                                    @input="inputAttribute($event, attr_index)"></b-form-input>
                                </div>
                                <div class="w-100" v-if="attribute_values.length">
                                    <div class="w-100">
                                        <label class="input-label">Combinations: </label>
                                    </div>
                                    <div class="py-2 d-flex flex-column" v-for="(attribute_value, attr_val_index) in attribute_values">
                                        <span>{{ Object.keys(attribute_value).filter(e => !['price', 'stock'].includes(e)).map(e => attribute_value[e]).join('-') }}</span>
                                        <div class="d-flex">
                                            <b-form-input type="number" placeholder="Price" v-model="attribute_value.price"></b-form-input>
                                            <b-form-input type="number" placeholder="Stock" v-model="attribute_value.stock"></b-form-input>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </template>
                        <template v-else>
                            <div class="d-flex flex-row w-100">
                                <div class="d-flex flex-column align-items-left w-100">
                                    <div class="w-100">
                                        <label class="input-label">Stock: </label>
                                    </div>
                                    <div class="w-100">
                                        <b-form-input placeholder="Stock"
                                            v-model="otherProductData.stock"></b-form-input>
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex flex-row w-100">
                                <div class="d-flex flex-column align-items-left w-100">
                                    <div class="w-100">
                                        <label class="input-label">Unit Price (Selling Price) (₹): </label>
                                    </div>
                                    <div class="w-100">
                                        <b-form-input placeholder="Unit Price (Selling Price) (₹)"
                                            v-model="otherProductData.price"></b-form-input>
                                    </div>
                                </div>
                            </div>
                        </template>
                        <div class="d-flex flex-row w-100">
                            <div class="d-flex flex-column align-items-left w-100">
                                <div class="w-100">
                                    <label class="input-label">Actual Price (MRP) (₹): </label>
                                </div>
                                <div class="w-100">
                                    <b-form-input placeholder="Compare Price"
                                        v-model="otherProductData.compare_price"></b-form-input>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row w-100">
                            <div class="d-flex flex-column align-items-left w-100">
                                <div class="w-100">
                                    <label class="input-label">GST (%): </label>
                                </div>
                                <div class="w-100">
                                    <b-form-input placeholder="GST" v-model="otherProductData.gst"></b-form-input>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row w-100">
                            <div class="d-flex flex-column align-items-left w-100">
                                <div class="w-100">
                                    <label class="input-label">Packing Charges: </label>
                                </div>
                                <div class="w-100">
                                    <b-form-input placeholder="Packing Charges" v-model="otherProductData.packing_charges"></b-form-input>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row w-100">
                            <div class="d-flex flex-column align-items-left w-100">
                                <div class="w-100">
                                    <label class="input-label">Weight (In KG): </label>
                                </div>
                                <div class="w-100">
                                    <b-form-input placeholder="Weight (In KG)" v-model="otherProductData.weight"></b-form-input>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-column align-items-left w-100">
                            <div class="w-100">
                                <label class="input-label">Free Delivery: </label>
                            </div>
                            <div class="w-100">
                                <b-form-checkbox v-model="otherProductData.free_delivery" name="check-button" switch>{{ otherProductData.free_delivery ? 'Free Delivery Available' : 'Free Delivery Not Available.' }}</b-form-checkbox>
                            </div>
                            <div class="w-100">
                                <b-form-input :disabled="!otherProductData.free_delivery" placeholder="Free Delivery If More" v-model="otherProductData.free_delivery_if_more"></b-form-input>
                            </div>
                        </div>
                        <div class="d-flex flex-column align-items-left w-100">
                            <div class="w-100">
                                <label class="input-label">Exchange Policy: </label>
                            </div>
                            <div class="w-100">
                                <b-form-checkbox v-model="otherProductData.exchange_available" name="check-button" switch>{{ otherProductData.exchange_available ? 'Exchange Available' : 'Exchange Not Available.' }}</b-form-checkbox>
                            </div>
                            <div class="w-100">
                                <b-form-textarea
                                    :disabled="!otherProductData.exchange_available"
                                    id="textarea"
                                    v-model="otherProductData.exchange_policy"
                                    placeholder="Exchange Policy."
                                    rows="3"
                                    max-rows="6"
                                ></b-form-textarea>
                            </div>
                        </div>
                        <div class="d-flex flex-column align-items-left w-100">
                            <div class="w-100">
                                <label class="input-label">Cancellation Policy: </label>
                            </div>
                            <div class="w-100">
                                <b-form-checkbox v-model="otherProductData.cancellation_available" name="check-button" switch>{{ otherProductData.cancellation_available ? 'Cancellation Available' : 'Cancellation Not Available.' }}</b-form-checkbox>
                            </div>
                            <div class="w-100">
                                <b-form-textarea
                                    :disabled="!otherProductData.cancellation_available"
                                    id="textarea"
                                    v-model="otherProductData.cancellation_policy"
                                    placeholder="Cancellation Policy."
                                    rows="3"
                                    max-rows="6"
                                ></b-form-textarea>
                            </div>
                        </div>
                    </div>
                </template>
                <template
                    v-if="selected_category && ['Food', 'Food Court'].includes(category_list.find(e => e.id == selected_category).category_name)">
                    <div class="d-flex flex-row w-100">
                        <div class="d-flex flex-row align-items-center w-100">
                            <div class="w-50">
                                <label class="input-label">Food Type: </label>
                            </div>
                            <div class="w-50 pt-3 d-flex flex-row-reverse">
                                <b-form-group v-slot="{ ariaDescribedby }">
                                    <b-form-radio-group id="btn-radios-2" v-model="selected_food_type" :options="food_types"
                                        :aria-describedby="ariaDescribedby"
                                        :button-variant="selected_food_type == 'VEG' ? 'outline-success' : 'outline-danger'"
                                        size="sm" name="radio-btn-outline" buttons></b-form-radio-group>
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
                                <b-form-textarea id="textarea" v-model="foodData.description"
                                    placeholder="Product Description.." rows="3" max-rows="6"></b-form-textarea>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex flex-row w-100">
                        <div class="d-flex flex-column align-items-left w-100">
                            <div class="w-100">
                                <label class="input-label">Product Timings: </label>
                            </div>
                            <div class="w-100 d-flex flex-row align-items-center" style="gap: 15px !important;">
                                <b-form-checkbox class="w30" v-model="foodData.hasTime" switch><span class="text-heading"
                                        style="margin-left: 0px !important;">Has Time</span></b-form-checkbox>
                                <b-form-timepicker class="w30" v-model="foodData.openTime" placeholder="time"
                                    locale="en"></b-form-timepicker>
                                <b-form-timepicker class="w30" v-model="foodData.closeTime" placeholder="time"
                                    locale="en"></b-form-timepicker>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex flex-row w-100">
                        <div class="d-flex flex-column align-items-left w-100">
                            <div class="w-100">
                                <label class="input-label">Product Images: </label>
                            </div>
                            <div class="w-100">
                                <input @input="handleFile($event)" accept="image/*" type="file" id="files" name="files"
                                    multiple />
                            </div>
                            <div class="d-flex flex-row" v-if="title == 'Edit Product'" style="
                                    padding: 10px;
                                    overflow-x: scroll !important;
                                    width: 100% !important;
                                    object-fit: cover;
                                ">
                                <div class="d-flex flex-row" style="
                                        gap: 10px;
                                    ">
                                    <div class="d-flex flex-column gap8" style="height: max-content; width: max-content;"
                                        v-for="(image, image_index) in selected_images" :key="image_index">
                                        <img style="height: 100px !important; width: 100px !important; border-radius: 16px;"
                                            :src="image.image_url" alt="Image">
                                        <button @click.prevent="deleteImage(image, image_index)"
                                            class="w100 btn btn-danger"><i class="fa fa-trash mr-2"></i>Delete</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card d-flex flex-column p-3 mt-3" style="border-radius: 16px;">
                        <div class="d-flex flex-row w-100">
                            <div class="d-flex flex-column align-items-left w-100">
                                <div class="w-100">
                                    <label class="input-label">Selling Price (₹): </label>
                                </div>
                                <div class="w-100">
                                    <b-form-input v-model="foodData.price" placeholder="Price"></b-form-input>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row w-100">
                            <div class="d-flex flex-column align-items-left w-100">
                                <div class="w-100">
                                    <label class="input-label">Actual Price (MRP) (₹): </label>
                                </div>
                                <div class="w-100">
                                    <b-form-input placeholder="Compare Price"
                                        v-model="foodData.compare_price"></b-form-input>
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
                        <div class="d-flex flex-row w-100">
                            <div class="d-flex flex-column align-items-left w-100">
                                <div class="w-100">
                                    <label class="input-label">Packing Charges: </label>
                                </div>
                                <div class="w-100">
                                    <b-form-input placeholder="Packing Charges"
                                        v-model="foodData.packing_charges"></b-form-input>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row w-100">
                            <div class="d-flex flex-column align-items-left w-100">
                                <div class="w-100">
                                    <label class="input-label">Weight (In KG): </label>
                                </div>
                                <div class="w-100">
                                    <b-form-input placeholder="Weight (In KG)" v-model="foodData.weight"></b-form-input>
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
import Joi from 'joi';
import vSelect from 'vue-select';
import LoaderComp from './loader.vue';
export default {
    components: {
        LoaderComp,
        vSelect
    },
    props: [
        'edit_data',
        'visible',
        'title',
        'product_data'
    ],
    data() {
        return {
            attributes_list: [
                {
                    id: 1,
                    attribute_name: 'COLOR',
                    attribute: null,
                    attributes: []
                },
                {
                    id: 2,
                    attribute_name: 'SIZE',
                    attribute: null,
                    attributes: []
                },
            ],
            selected_attributes: [],
            attribute_values: [],


            update_id: null,
            innerLoader: false,
            selected_images: [],
            loader: false,
            category_list: [],
            selected_category: null,
            sub_category_list: [],
            selected_sub_category: [],
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
                weight: null,
                gst: null,
                packing_charges: null,
            },
            otherProductData: {
                title: null,
                description: null,
                files: null,
                compare_price: null,
                price: null,
                stock: null,
                weight: null,
                gst: null,
                packing_charges: null,
                // negociation: false,
                free_delivery: false,
                free_delivery_if_more: 0,
                exchange_available: false,
                exchange_policy: null,
                cancellation_available: false,
                cancellation_policy: null,
            },
            created_product_id: null,
        }
    },
    watch: {
        async selected_category(val) {
            if (val) {
                console.log(val);
                this.fetchSubCategories()
                this.fetchAttributes()
            }
        },
        async selected_vendor(val) {
            if (val) {
                await this.fetchCategories()
            }
        },
        async visible(val) {
            this.loader = true
            console.log('product_data', this.product_data);
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
        async fetchAttributes() {
            try {
                let url = '/fetch-attributes'
                if (this.category_list.find(e => e.id == this.selected_category).id) {
                    url = `${url}?category_id=${this.category_list.find(e => e.id == this.selected_category).id}`
                }
                const response = await this.$axios.get(url)
                this.attributes_list = response.data.attributes.map(e => {
                    return {
                        id: e.id,
                        attribute_name: e.attribute_name,
                        attribute: null,
                        attributes: []
                    }
                })
            } catch (error) {
                console.log(error);
            }
        },
        setAttributeValues(data) { //Array of array
            this.attribute_values = []
            for (const iterator of data) {
                let combo = {}
                for (const iterator2 of iterator) {
                    combo[Object.keys(iterator2)[0]] = iterator2[Object.keys(iterator2)[0]]
                }
                this.attribute_values.push({
                    ...combo,
                    price: null,
                    stock: null
                }) // array of objects
                console.log("combinations: ",this.attribute_values);
            }
        },
        generateCombinations(attributeObjects) {
            function generateCombinationsRecursive(index, currentCombination, result) {
                if (index === attributeObjects.length) {
                    result.push([...currentCombination]);
                    return;
                }

                const currentObject = attributeObjects[index];

                if (currentObject.attributes && currentObject.attributes.length > 0) {
                    for (const attributeValue of currentObject.attributes) {
                        currentCombination.push({ [currentObject.attribute_name]: attributeValue });
                        generateCombinationsRecursive(index + 1, currentCombination, result);
                        currentCombination.pop();
                    }
                } else {
                    // If current object has no attributes, skip to the next object
                    generateCombinationsRecursive(index + 1, currentCombination, result);
                }
            }

            const result = [];
            generateCombinationsRecursive(0, [], result);
            this.setAttributeValues(result)
        },
        async inputAttribute(event, attr_index) {
            const commaAtEnd = event[event.length - 1]
            if (commaAtEnd == ',' ? true : false) {
                this.selected_attributes[attr_index].attributes.push(event.replace(',', ''))
                this.selected_attributes[attr_index].attribute = null
            }
            this.generateCombinations(this.selected_attributes)
        },
        async deleteImage(image, image_index) {
            try {
                if (image.id != 0) {
                    await this.deleteWithPopup('/delete-product-image', 'product_image_id', image.id, image_index)
                } else {
                    this.$toast.show('The dummy image cannot be deleted.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                }
            } catch (error) {
                console.log(error);
            }
        },
        async deleteWithPopup(path, key, data_id, index = null) {
            try {
                const h = this.$createElement
                const id = `DeleteModal${id}`
                this.$bvToast.hide(id)
                const $closeButton = h(
                    'b-button',
                    {
                        on: {
                            click: () => {
                                this.$bvToast.hide(id)
                            }
                        },
                        class: 'btn btn-primary mx-1',
                        style: 'margin: 0 auto;'
                    },
                    'No'
                )
                const $acceptButton = h(
                    'b-button',
                    {
                        on: {
                            click: async () => {
                                let data = {}
                                data[key] = data_id
                                const deleteresponse = await this.$axios.post(path, data)
                                this.$toast.show(deleteresponse.data.message, {
                                    duration: 1500,
                                    position: 'top-right',
                                    keepOnHover: true,
                                    type: deleteresponse.data.status
                                })
                                if (index != null) {
                                    this.selected_images.splice(index, 1)
                                }
                                this.$bvToast.hide(id)
                            }
                        },
                        class: 'btn btn-danger mx-1',
                    },
                    'Yes'
                )
                const $buttonContainer = h(
                    'div',
                    {
                        class: 'text-center my-2',
                    },
                    [$closeButton, $acceptButton]
                )
                this.$bvToast.toast($buttonContainer, {
                    id: id,
                    title: `Are you sure?`,
                    noCloseButton: true,
                })
            } catch (error) {
                console.log(error);
            }
        },
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
                hasTime: false,
                openTime: null,
                closeTime: null,
                compare_price: null,
                weight: null,
                gst: null,
                packing_charges: null,
            }
            this.otherProductData = {
                title: null,
                description: null,
                files: null,
                price: null,
                compare_price: null,
                weight: null,
                gst: null,
                packing_charges: null,
                // negociation: false,
                free_delivery: false,
                free_delivery_if_more: 0,
                exchange_available: false,
                exchange_policy: null,
                cancellation_available: false,
                cancellation_policy: null,
            }
            this.attributes_list = [],
            this.selected_attributes = [],
            this.attribute_values = [],
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
                this.vendor_list = response.data.vendors.map(e => {
                    return {
                        ...e,
                        fullname: `${e.fullname} (${e.store.name})`
                    }
                })
                this.vendor_list.unshift({
                    id: null,
                    fullname: 'Select a vendor'
                })
            } catch (error) {
                console.log(error);
            }
        },
        async fetchSubCategories() {
            try {
                this.innerLoader = true
                const path = `/fetch-sub-category?category=${this.category_list.find(e => e.id == this.selected_category).category_name.replaceAll('&', "%26")}`
                console.log(path);
                const response = await this.$axios.get(path)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.sub_category_list = response.data.subCategories.map(e => ({ id: e.id, name: e.name }))
                this.innerLoader = false
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
                    await this.saveProductData()
                }
            } catch (error) {
                console.log(error);
            }
            this.loader = false
        },
        async check_product_data(data, type = 'ADD') {
            try {
                if (type == 'ADD') {
                    const productModel = Joi.object({
                        vendor_id: Joi.number().required(),
                        name: Joi.string().max(255).required(),
                        description: Joi.string().max(1000).allow(null).allow(''),
                        total_price: Joi.number().required(),
                        packing_charges: Joi.number().allow(null).default(0),
                        compare_price: Joi.number().required(),
                        gst: Joi.number().required(),
                        negociation: Joi.boolean().default(false).allow(null),
                        tags: Joi.string().allow(null).allow(''),
                        free_delivery: Joi.boolean().required().default(false),
                        free_delivery_if_more: Joi.number().allow(null).allow(0),
                        exchange_available: Joi.boolean().required().default(true),
                        exchange_policy: Joi.string().max(1000).allow(null).allow(''),
                        cancellation_available: Joi.boolean().required().default(true),
                        cancellation_policy: Joi.string().max(1000).allow(null).allow(''),
                        stock: Joi.number().integer().required(),
                        category: Joi.object({
                            id: Joi.number().integer().required(),
                            category_name: Joi.string().required(),
                            table_name: Joi.string().required()
                        }).required(),
                        sub_categories: Joi.array().items(Joi.object({
                            id: Joi.number().integer().required(),
                            name: Joi.string().required()
                        })).allow(null).empty(Joi.array().max(0)),
                        combination: Joi.array().items(Joi.object({
                            combinations: Joi.array().items(Joi.object({
                                attribute_id: Joi.number().integer().required(),
                                attribute_value: Joi.string().required()
                            })).required(),
                            combination_name: Joi.string().required(),
                            price: Joi.number().required(),
                            stock: Joi.number().required(),
                        })).required(),
                        stock: Joi.number().required(),
                        available: Joi.boolean().default(true).required(),
                    })
                    const result = await productModel.validateAsync(data)
                    return result
                } else {
                    const updateProductModel = Joi.object({
                        product_id: Joi.number().required(),
                        vendor_id: Joi.number().required(),
                        name: Joi.string().max(255).required(),
                        description: Joi.string().max(1000).allow(null).allow(''),
                        total_price: Joi.number().required(),
                        packing_charges: Joi.number().allow(null).default(0),
                        compare_price: Joi.number().required(),
                        gst: Joi.number().required(),
                        negociation: Joi.boolean().default(false).allow(null),
                        tags: Joi.string().allow(null).allow(''),
                        free_delivery: Joi.boolean().required().default(false),
                        free_delivery_if_more: Joi.number().allow(null).allow(0),
                        exchange_available: Joi.boolean().required().default(true),
                        exchange_policy: Joi.string().max(1000).allow(null).allow(''),
                        cancellation_available: Joi.boolean().required().default(true),
                        cancellation_policy: Joi.string().max(1000).allow(null).allow(''),
                        stock: Joi.number().integer().required(),
                        category: Joi.object({
                            id: Joi.number().integer().required(),
                            category_name: Joi.string().required(),
                            table_name: Joi.string().required()
                        }).required(),
                        sub_categories: Joi.array().items(Joi.object({
                            id: Joi.number().integer().required(),
                            name: Joi.string().required()
                        })).allow(null).empty(Joi.array().max(0)),
                        combination: Joi.array().items(Joi.object({
                            combinations: Joi.array().items(Joi.object({
                                attribute_id: Joi.number().integer().required(),
                                attribute_value: Joi.string().required()
                            })).required(),
                            combination_name: Joi.string().required(),
                            price: Joi.number().required(),
                            stock: Joi.number().required(),
                        })).required(),
                        stock: Joi.number().required(),
                        available: Joi.boolean().default(true).required(),
                    })
                    const result = await updateProductModel.validateAsync(data)
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
        async saveProductData() {
            this.loader = true
            try {
                const category = this.category_list.find(e => e.id == this.selected_category)
                delete category.image
                let addData = this.update_id ? {
                    product_id: this.update_id,
                    vendor_id: this.selected_vendor,
                    name: this.otherProductData.title,
                    description: this.otherProductData.description,
                    packing_charges: this.otherProductData.packing_charges,
                    compare_price: this.otherProductData.compare_price,
                    gst: this.otherProductData.gst,
                    category: category,
                    sub_categories: this.selected_sub_category,
                    available: true,
                    // negociation: this.otherProductData.negociation,
                    free_delivery: this.otherProductData.free_delivery,
                    free_delivery_if_more: this.otherProductData.free_delivery_if_more,
                    exchange_available: this.otherProductData.exchange_available,
                    exchange_policy: this.otherProductData.exchange_policy,
                    cancellation_available: this.otherProductData.cancellation_available,
                    cancellation_policy: this.otherProductData.cancellation_policy,
                } : {
                    vendor_id: this.selected_vendor,
                    name: this.otherProductData.title,
                    description: this.otherProductData.description,
                    packing_charges: this.otherProductData.packing_charges,
                    compare_price: this.otherProductData.compare_price,
                    gst: this.otherProductData.gst,
                    category: category,
                    sub_categories: this.selected_sub_category,
                    available: true,
                    // negociation: this.otherProductData.negociation,
                    free_delivery: this.otherProductData.free_delivery,
                    free_delivery_if_more: this.otherProductData.free_delivery_if_more,
                    exchange_available: this.otherProductData.exchange_available,
                    exchange_policy: this.otherProductData.exchange_policy,
                    cancellation_available: this.otherProductData.cancellation_available,
                    cancellation_policy: this.otherProductData.cancellation_policy,
                }
                const addedAttributeData = this.attribute_values.map(attribute_value => {
                    return {
                        combinations: Object.keys(attribute_value).filter(e => !['price', 'stock'].includes(e)).map(e => {
                            return {
                                attribute_id: this.selected_attributes.find(el => el.attribute_name == e).id,
                                attribute_value: attribute_value[e]
                            }
                        }),
                        combination_name: Object.keys(attribute_value).filter(e => !['price', 'stock'].includes(e)).map(e => attribute_value[e]).join('-'),
                        price: attribute_value.price,
                        stock: attribute_value.stock
                    }
                })
                addData.combination = addedAttributeData.filter(e => e.combination_name && e.combination_name != '').length ? addedAttributeData : []
                addData.total_price = addedAttributeData.filter(e => e.combination_name && e.combination_name != '').length ? addedAttributeData.sort((a,b) => Number(b.price) - Number(a.price))[0].price : Number(this.otherProductData.price)
                addData.stock = addedAttributeData.filter(e => e.combination_name && e.combination_name != '').length ? addedAttributeData.sort((a,b) => Number(b.price) - Number(a.price))[0].stock : Number(this.otherProductData.stock)
                const result = await this.check_product_data(addData, this.update_id ? 'EDIT' : 'ADD')
                if (!result) return
                const response = await this.$axios({
                    method: 'post',
                    url: this.update_id ? '/update-product-without-images' : `/add-product-without-images`,
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
                this.created_product_id = this.update_id ? { id: this.update_id } : response.data.created_product
                await this.saveImage()
                this.resetForm()
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
                        packing_charges: Joi.number().allow(null).default(0),
                        free_delivery: Joi.boolean().required().default(false),
                        free_delivery_if_more: Joi.number().allow(null).allow(0),
                        weight: Joi.number().allow(null).default(0.5),
                        packing_charges: Joi.number().allow(null).default(0),
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
                        packing_charges: Joi.number().allow(null).default(0),
                        gst: Joi.number().required(),
                        food_type: Joi.string().allow(null),
                        tags: Joi.string().allow(null).allow(''),
                        free_delivery: Joi.boolean().required().default(false),
                        free_delivery_if_more: Joi.number().allow(null).allow(0),
                        weight: Joi.number().allow(null).default(0.5),
                        packing_charges: Joi.number().allow(null).default(0),
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
                    packing_charges: this.foodData.packing_charges,
                    compare_price: this.foodData.compare_price,
                    gst: this.foodData.gst,
                    food_type: this.selected_food_type,
                    category: category,
                    sub_categories: this.selected_sub_category,
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
                    packing_charges: this.foodData.packing_charges,
                    compare_price: this.foodData.compare_price,
                    gst: this.foodData.gst,
                    food_type: this.selected_food_type,
                    category: category,
                    sub_categories: this.selected_sub_category,
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
                this.created_product_id = this.update_id ? { id: this.update_id } : response.data.created_product
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
        async setVendor(vendor_id) {
            this.selected_vendor = vendor_id
            await this.fetchCategories()
        },
        async setCategory(category_id) {
            this.selected_category = category_id
            await this.fetchSubCategories()
        },
        async placeProductData(data) {
            this.loader = true
            this.update_id = data.id
            await this.setVendor(data.vendor_id)
            await this.fetchCategories()
            const category = this.category_list.find(e => e.id == data.category_id).category_name
            await this.setCategory(data.category_id)
            if (['Food', 'Food Court'].includes(this.category_list.find(e => e.category_name == category).category_name)) {
                this.selected_sub_category = data?.vendor_sub_category_product_associations?.length ? data.vendor_sub_category_product_associations.map(e => {
                    console.log(e);
                    return {
                        id: e.sub_category_id,
                        name: e.vendor_sub_category.name
                    }
                }) : []
                console.log('1198', data);
                this.selected_food_type = data.food_type
                this.foodData.title = data.name
                this.foodData.description = data.description
                this.foodData.compare_price = data.compare_price
                this.foodData.price = data.price
                this.foodData.gst = data.gst
                this.foodData.hasTime = Boolean(data.has_time)
                this.foodData.openTime = data.open_time
                this.foodData.closeTime = data.close_time
                this.foodData.packing_charges = data.packing_charges
                this.foodData.weight = data.weight
                this.selected_images = data.images_of_products
                return
            } else {
                this.selected_sub_category = data?.vendor_sub_category_product_associations?.length ? data.vendor_sub_category_product_associations.map(e => {
                    return {
                        id: e.sub_category_id,
                        name: e.vendor_sub_category.name
                    }
                }) : []
                await this.fetchAttributes()
                // console.log(this.attributes_list);
                const variants_data = data.product_variants
                for (const variant of variants_data) {
                    for (const combo of variant.combination_details) {
                        // console.log('combo',combo);
                        // console.log('this.attributes_list',this.attributes_list);
                        const selected_attribute = this.attributes_list.find(e => e.id == combo.attribute_id)
                        // console.log('combo.attribute_id', combo.attribute_id);
                        const avl_data = this.selected_attributes.find(e => e == selected_attribute)
                        if (!avl_data) {
                            this.selected_attributes.push(selected_attribute)
                            const avl_index = this.selected_attributes.indexOf(selected_attribute)
                            // console.log('selected_attributes',this.selected_attributes);
                            // console.log(avl_index);
                            if (!this.selected_attributes[avl_index].attributes.find(e => e == combo.attribute_value)) {
                                this.selected_attributes[avl_index].attributes.push(combo.attribute_value)
                            }
                        } else {
                            const avl_index = this.selected_attributes.indexOf(avl_data)
                            if (!this.selected_attributes[avl_index].attributes.find(e => e == combo.attribute_value)) {
                                this.selected_attributes[avl_index].attributes.push(combo.attribute_value)
                            }
                        }
                    }
                }
                await this.generateCombinations(this.selected_attributes)
                this.attribute_values.forEach(attribute_value => {
                    let objectToFind = {}
                    Object.keys(attribute_value).filter(e => e != 'price' && e != 'stock').forEach(e => {
                        objectToFind[e] = attribute_value[e]
                    })
                    const avl_data = variants_data.find(item => {
                        return item.combination_details.every(comboItem => objectToFind[comboItem.category_attribute.attribute_name] === comboItem.attribute_value);
                    });
                    if (avl_data) {
                        attribute_value.price = avl_data.price
                        attribute_value.stock = avl_data.stock
                    }
                })
                this.selected_food_type = data.food_type
                this.otherProductData.title = data.name
                this.otherProductData.description = data.description
                this.otherProductData.compare_price = data.compare_price
                this.otherProductData.price = data.price
                this.otherProductData.stock = data.available_stocks
                this.otherProductData.gst = data.gst
                this.otherProductData.hasTime = Boolean(data.has_time)
                this.otherProductData.openTime = data.open_time
                this.otherProductData.closeTime = data.close_time
                this.otherProductData.packing_charges = data.packing_charges
                this.otherProductData.weight = data.weight
                this.selected_images = data.images_of_products
            }
            this.loader = false
        },
        async logout() {
            localStorage.removeItem('token')
            // localStorage.removeItem('refreshToken')
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

.selected_attribute {
    width: max-content;
    border: 2px solid #e74c3d;
    padding: 5px 20px;
    border-radius: 50px;
    gap: 15px;
    background: #ffc1ba;
    color: white;
    font-weight: 700;
    box-shadow: rgba(0, 0, 0, 0.16) 0px 6px 4px;
}

.selected_attribute_container {
    display: flex;
    gap: 10px;
    font-size: 18px;
    margin-bottom: 10px;
    flex-wrap: wrap;
    margin-top: 10px;
    margin-bottom: 10px;
}


.attribute_cross_button {
    background: #f46767;
    padding: 3px 5px;
    border-radius: 5px;
}
</style>