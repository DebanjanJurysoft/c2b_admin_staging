<template>
    <div class="vendor-form-container d-flex flex-column">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="tabs-content">
            <div>
                <h3 class="add-vendor-heading text-center">Add Vendor</h3>
            </div>
            <div class="progress-state">
                <template v-for="(progress_item, progress_index) in progress.filter(e => e.disable === false)">
                    <div class="progress" :class="progress_item.completed ? 'progress-completed' : ''" :key="progress_index">
                        <i style="progress_item.completed ? 'color: #30D158;' : 'color: #1C1C1E' " class='bx bx-check-circle mr-2'></i>
                        <span>{{progress_item.name}}</span>
                    </div>
                    <span class="progress ml-3 mr-3" :class="progress[progress_index + 1].completed ? 'progress-completed' : ''"  v-if="progress_index < progress.filter(e => e.disable === false).length - 1">
                        {{'------>'}}
                    </span>
                </template>
            </div>
            <div class="add-vendor-form">
                <div class="w-100" v-if="progress[in_progress_index].name == 'Profile'">
                    <div class="d-flex flex-column w-100 login-details-area" style="gap: 5px;">
                        <span class="text-center h3">Login Details</span>
                        <div class="d-flex flex-row">
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Full Name: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input  type="text" v-model="vendor_data.profile.fullname" placeholder="Full Name" />
                                    </div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Email: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="text" v-model="vendor_data.profile.email" placeholder="Email" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row">
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Password: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="password" v-model="vendor_data.profile.password" placeholder="Password" />
                                    </div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Confirm: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="password" v-model="vendor_data.profile.confirm_password" placeholder="Confirm Password" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="w-100" v-if="progress[in_progress_index].name == 'Profile'">
                    <div class="d-flex flex-column w-100 login-details-area" style="gap: 5px;">
                        <span class="text-center h3">Personal Details</span>
                        <div class="d-flex flex-row">
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">First Name: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="text" v-model="vendor_data.personal.first_name" placeholder="First Name" />
                                    </div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Last Name: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="text" v-model="vendor_data.personal.last_name" placeholder="Last Name" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row">
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">DOB: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="date" v-model="vendor_data.personal.dob" />
                                    </div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Gender: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-select v-model="vendor_data.personal.gender" :options="gender_list"></b-form-select>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row">
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Language: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="text" v-model="vendor_data.personal.language" placeholder="Languages"/>
                                    </div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Email: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="text" v-model="vendor_data.personal.email" placeholder="Email" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row">
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Phone: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="text" v-model="vendor_data.personal.phone" placeholder="Phone Number" />
                                    </div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Alternative Phone: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="text" v-model="vendor_data.personal.alt_phone" placeholder="Alternative Phone Number" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <span class="text-center h3">Address</span>
                        <div class="d-flex flex-row address-area">
                            <div class="d-flex flex-column col-12">
                                <div class="d-flex flex-row">
                                    <div class="col-6">
                                         <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Country: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" v-model="vendor_data.personal.country" placeholder="Country" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">State: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" v-model="vendor_data.personal.state" placeholder="State" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex flex-row">
                                    <div class="col-6">
                                         <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">City: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" v-model="vendor_data.personal.city" placeholder="City" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Pincode: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" v-model="vendor_data.personal.pincode" placeholder="Pincode" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex flex-row">
                                    <div class="col-6">
                                         <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Area: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" v-model="vendor_data.personal.area" placeholder="Area" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Street Number / Name: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" v-model="vendor_data.personal.add2" placeholder="Street Number / Name" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex flex-row">
                                    <div class="col-6">
                                         <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Door No, Floor, Apartment: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" v-model="vendor_data.personal.add1" placeholder="Door No, Floor, Apartment" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Landmark: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" v-model="vendor_data.personal.landmark" placeholder="Landmark" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex flex-row">
                                    <div class="col-6">
                                         <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Lattitude: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="number" v-model="vendor_data.personal.lat" placeholder="Lattitude" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Longitude: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="number" v-model="vendor_data.personal.lng" placeholder="Longitude" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row">
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Identity Proof Type: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-select v-model="vendor_data.personal.identity_proof" :options="identity_proof_list"></b-form-select>
                                    </div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Identity Proof File: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-file v-model="vendor_data.personal.identity_proof_file" ref="file-input" class="mb-2"></b-form-file>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="store-section w-100" v-if="progress[in_progress_index].name == 'Store'">
                    <div class="d-flex flex-column w-100 login-details-area" style="gap: 5px;">
                        <span class="text-center h3">Store Details</span>
                        <div class="d-flex flex-row">
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Type Market Place: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-select v-model="vendor_data.store.type_market_place" :options="type_market_place_list"></b-form-select>
                                    </div>
                                </div>
                            </div>
                            <div class="col-6" v-if="vendor_data.store.type_market_place == 'PRODUCT'">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Product Type: </label>
                                    </div>
                                    <div class="col-12">
                                        <vSelect 
                                            class="v-select"
                                            multiple
                                            v-model="vendor_data.store.selected_product"
                                            :label="'category_name'"
                                            :options="categories_list"
                                        ></vSelect>
                                    </div>
                                </div>
                            </div>
                            <div class="col-6" v-if="vendor_data.store.type_market_place == 'SERVICES'">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Service Type: </label>
                                    </div>
                                    <div class="col-12">
                                        <vSelect 
                                            class="v-select"
                                            multiple
                                            v-model="vendor_data.store.selected_service"
                                            :label="'name'"
                                            :options="services_list"
                                        ></vSelect>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div v-if="vendor_data.store.type_market_place == 'SERVICES'">
                            <div class="d-flex flex-row">
                                <div class="col-6">
                                    <div class="d-flex flex-column align-items-left">
                                        <div class="col-12">
                                            <label class="input-label">Phone: </label>
                                        </div>
                                        <div class="col-12">
                                            <b-form-input type="text" v-model="vendor_data.store.mobile" placeholder="Phone NUmber"/>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-6">
                                    <div class="d-flex flex-column align-items-left">
                                        <div class="col-12">
                                            <label class="input-label">Alt Phone: </label>
                                        </div>
                                        <div class="col-12">
                                            <b-form-input type="text" v-model="vendor_data.store.alt_mobile" placeholder="Alternative Phone Number"/>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex flex-row">
                                <div class="col-6">
                                    <div class="d-flex flex-column align-items-left">
                                        <div class="col-12">
                                            <label class="input-label">Email: </label>
                                        </div>
                                        <div class="col-12">
                                            <b-form-input type="text" v-model="vendor_data.store.email" placeholder="Email"/>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-6">
                                    <div class="d-flex flex-column align-items-left">
                                        <div class="col-12">
                                            <label class="input-label">Blank Cheque: </label>
                                        </div>
                                        <div class="col-12">
                                            <b-form-file v-model="vendor_data.store.blank_cheque" ref="file-input" class="mb-2"></b-form-file>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div v-if="vendor_data.store.type_market_place == 'PRODUCT'">
                            <div class="d-flex flex-row">
                                <div class="col-6">
                                    <div class="d-flex flex-column align-items-left">
                                        <div class="col-12">
                                            <label class="input-label">Store / Company Name: </label>
                                        </div>
                                        <div class="col-12">
                                            <b-form-input type="text" v-model="vendor_data.store.store_name" placeholder="Store / Company Name:"/>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-6">
                                    <div class="d-flex flex-column align-items-left">
                                        <div class="col-12">
                                            <label class="input-label">GST Number: </label>
                                        </div>
                                        <div class="col-12">
                                            <b-form-input type="text" v-model="vendor_data.store.gst_no" placeholder="GST Number"/>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex flex-row">
                                <div class="col-6">
                                    <div class="d-flex flex-column align-items-left">
                                        <div class="col-12">
                                            <label class="input-label">FSSAI Number: </label>
                                        </div>
                                        <div class="col-12">
                                            <b-form-input type="text" v-model="vendor_data.store.fssai_no" placeholder="FSSAI Number"/>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-6">
                                    <div class="d-flex flex-column align-items-left">
                                        <div class="col-12">
                                            <label class="input-label">Phone: </label>
                                        </div>
                                        <div class="col-12">
                                            <b-form-input type="text" v-model="vendor_data.store.mobile" placeholder="Phone Number"/>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex flex-row">
                                <div class="col-6">
                                    <div class="d-flex flex-column align-items-left">
                                        <div class="col-12">
                                            <label class="input-label">Alt Phone: </label>
                                        </div>
                                        <div class="col-12">
                                            <b-form-input type="text" v-model="vendor_data.store.alt_mobile" placeholder="Alternative Phone Number"/>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-6">
                                    <div class="d-flex flex-column align-items-left">
                                        <div class="col-12">
                                            <label class="input-label">Email: </label>
                                        </div>
                                        <div class="col-12">
                                            <b-form-input type="text" v-model="vendor_data.store.email" placeholder="Email"/>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex flex-row">
                                <div class="col-6">
                                    <div class="d-flex flex-column align-items-left">
                                        <div class="col-12">
                                            <label class="input-label">Choose Delivery Types: </label>
                                        </div>
                                        <div class="col-12">
                                            <vSelect 
                                                multiple
                                                @input="checkDeliveryTypes(vendor_data.store.delivery_types)"
                                                v-model="vendor_data.store.delivery_types"
                                                :label="'type'"
                                                :options="delivery_types_list"
                                            ></vSelect>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-6">
                                    <div class="d-flex flex-column align-items-left">
                                        <div class="col-12">
                                            <label class="input-label">Email: </label>
                                        </div>
                                        <div class="col-12">
                                            <b-form-input type="text" v-model="vendor_data.store.email" placeholder="Email"/>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <span class="text-center h3">Address</span>
                        <div class="d-flex flex-row address-area">
                            <div class="d-flex flex-column col-12">
                                <div class="d-flex flex-row">
                                    <div class="col-6">
                                         <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Country: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" placeholder="Country" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">State: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" placeholder="State" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex flex-row">
                                    <div class="col-6">
                                         <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">City: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" placeholder="City" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Pincode: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" placeholder="Pincode" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex flex-row">
                                    <div class="col-6">
                                         <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Area: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" placeholder="Area" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Street Number / Name: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" placeholder="Street Number / Name" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex flex-row">
                                    <div class="col-6">
                                         <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Door No, Floor, Apartment: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" placeholder="Door No, Floor, Apartment" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Landmark: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" placeholder="Landmark" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex flex-row">
                                    <div class="col-6">
                                         <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Lattitude: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="number" placeholder="Lattitude" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Longitude: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="number" placeholder="Longitude" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                </div>
                <div class="bank-section"></div>
            </div>
            <div class="button-move">
                <button class="prev-button" @click.prevent="goPrev" v-if="in_progress_index > 0"><i class='bx bx-left-arrow mr-2'></i> Prev</button>
                <button class="next-button" @click.prevent="goNext" v-if="in_progress_index < progress.filter(e => e.disable === false).length - 1">Next <i class='bx bx-right-arrow ml-2'></i></button>
                <button class="next-button" @click.prevent="goNext" v-if="in_progress_index == progress.filter(e => e.disable === false).length - 1">Save <i class='bx bx-save ml-2'></i></button>
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
            loader: false,
            in_progress_index: 0,
            progress: [
                {
                    id: 1,
                    name: 'Profile',
                    completed: true,
                    disable: false
                },
                {
                    id: 2,
                    name: 'Store',
                    completed: false,
                    disable: false
                },
                {
                    id: 3,
                    name: 'Bank Info',
                    completed: false,
                    disable: false
                },
            ],
            categories_list: [],
            services_list: [],
            date: null,
            gender_list: ['MALE', 'FEMALE', 'OTHERS'],
            type_market_place_list: ['PRODUCT', 'SERVICES'],
            delivery_types_list: [],
            identity_proof_list: ['PAN CARD', 'AADHAR CARD', 'VOTER CARD', 'PASSPORT', 'DRIVING LICENSE'],
            vendor_data: {
                profile: {
                    fullname: null,
                    email: null,
                    password: null,
                    confirm_password: null
                },
                personal: {
                    first_name: null,
                    last_name: null,
                    dob: null,
                    email: null,
                    gender: null,
                    language: null,
                    phone: null,
                    alt_phone: null,
                    add1: null,
                    add2: null,
                    area: null,
                    state: null,
                    city: null,
                    country: null,
                    pincode: null,
                    landmark: null,
                    lat: null,
                    lng: null,
                    identity_proof: null,
                    identity_proof_file: null,
                },
                store: {
                    type_market_place: 'PRODUCT',
                    selected_product: [],
                    selected_service: [],
                    store_name: null,
                    gst_no: null,
                    fssai_no: null,
                    mobile: null,
                    alt_mobile: null,
                    email: null,
                    add1: null,
                    add2: null,
                    area: null,
                    state: null,
                    city: null,
                    country: null,
                    pincode: null,
                    blank_cheque: null,
                    landmark: null,
                    lat: null,
                    lng: null,
                    delivery_types: [],
                    store_timings: [
                        {
                            day: 'SUNDAY',
                            open: null,
                            close: null,
                            status: null
                        },
                        {
                            day: 'MONDAY',
                            open: null,
                            close: null,
                            status: null
                        },
                        {
                            day: 'TUESDAY',
                            open: null,
                            close: null,
                            status: null
                        },
                        {
                            day: 'WEDNESDAY',
                            open: null,
                            close: null,
                            status: null
                        },
                        {
                            day: 'THURSDAY',
                            open: null,
                            close: null,
                            status: null
                        },
                        {
                            day: 'FRIDAY',
                            open: null,
                            close: null,
                            status: null
                        },
                        {
                            day: 'SATURDAY',
                            open: null,
                            close: null,
                            status: null
                        },
                    ],
                    store_image: null
                }
            },
            file: null,
        }
    },
    async mounted() {
        this.loader = true
        await this.fetchCategoryAndServices()
        await this.fetchDeliveryTypesList()
        this.loader = false
    },
    methods: {
        goNext() {
            if (this.in_progress_index + 1 == this.progress.filter(e => e.disable === false).length) {
                this.$toast.show('This Is The Last Step.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
            } else {
                this.in_progress_index += 1
                this.progress[this.in_progress_index].completed = true
            }
        },
        goPrev() {
            if (this.in_progress_index == 0) {
                this.$toast.show('This Is The First Step.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
            } else {
                this.progress[this.in_progress_index].completed = false
                this.in_progress_index -= 1
            }
        },
        checkDeliveryTypes(data) {
            if (data[data.length - 1].type == 'DUNZO DELIVERY' && data.find(e => e.type == "SELLER DELIVERY")) {
                const seller = data.find(e => e.type == "SELLER DELIVERY")
                const dunzo = data.find(e => e.type == "DUNZO DELIVERY")
                const index = data.indexOf(seller)
                this.vendor_data.store.delivery_types[index] = dunzo;
                this.vendor_data.store.delivery_types.pop()
            } else if (data[data.length - 1].type == 'SELLER DELIVERY' && data.find(e => e.type == "DUNZO DELIVERY")) {
                const seller = data.find(e => e.type == "SELLER DELIVERY")
                const dunzo = data.find(e => e.type == "DUNZO DELIVERY")
                const index = data.indexOf(dunzo)
                this.vendor_data.store.delivery_types[index] = seller;
                this.vendor_data.store.delivery_types.pop()
            }
        },
        async fetchCategoryAndServices() {
            try {
                const response = await this.$axios.get('/get-categories-and-services')
                this.categories_list = response.data.categories
                this.services_list = response.data.services
            } catch (error) {
                console.log(error);
            }
        },
        async fetchDeliveryTypesList() {
            try {
                const response = await this.$axios.get('/get-delivery-types')
                this.delivery_types_list = response.data.delivery_types
            } catch (error) {
                console.log(error);
            }
        },
        storeSelected(selected) {
            if (this.vendor_data.store.product) {
                console.log(this.vendor_data.store.product);
            }
        }
    }
}
</script>
