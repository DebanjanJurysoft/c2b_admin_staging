<template>
    <div class="vendor-form-container d-flex flex-column">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="tabs-content">
            <div class="progress-state">
                <template v-for="(progress_item, progress_index) in progress.filter(e => e.disable === false)" >
                    <div @click.prevent="in_progress_index = progress_index" class="progress" :class="progress_item.completed ? 'progress-completed' : ''" style="cursor: pointer;" :key="progress_index" >
                        <i style="progress_item.completed ? 'color: #30D158;' : 'color: #1C1C1E' " class='bx bx-check-circle mr-2'></i>
                        <span>{{progress_item.name}}</span>
                    </div>
                    <span class="progress ml-3 mr-3" :class="progress[progress_index + 1].completed ? 'progress-completed' : ''"  v-if="progress_index < progress.filter(e => e.disable === false).length - 1">
                        {{'------>'}}
                    </span>
                </template>
            </div>
            <div class="add-vendor-form">
                <div class="w-100" v-if="type != 'EDIT' && progress[in_progress_index].name == 'Profile' && !vendor_data.verify_otp && !vendor_data.otp_verified">
                    <div class="d-flex flex-column w-100 login-details-area" style="gap: 5px;">
                        <span class="text-center h3">Login Details</span>
                        <div class="d-flex flex-row">
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Full Name: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="text" v-model="vendor_data.profile.fullname" placeholder="Full Name" />
                                    </div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Email / Phone: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="text" v-model="vendor_data.profile.email" placeholder="Email / Phone" />
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
                                        <b-form-input type="text" v-model="vendor_data.profile.password" placeholder="Password" />
                                    </div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Confirm: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="text" v-model="vendor_data.profile.confirm_password" placeholder="Confirm Password" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row justify-content-center py-3">
                            <button class="prev-button" @click.prevent="sendOtp">Send OTP</button>
                        </div>
                    </div>
                </div>
                <div class="w-100" v-if="type != 'EDIT' && progress[in_progress_index].name == 'Profile' && vendor_data.verify_otp && !vendor_data.otp_verified">
                    <div class="d-flex flex-column w-100 login-details-area" style="gap: 5px;">
                        <span class="text-center h3">OTP Validate</span>
                        <div class="d-flex flex-column align-items-left">
                            <div class="col-12">
                                <label class="input-label">OTP: </label>
                            </div>
                            <div class="col-12">
                                <b-form-input type="text" v-model="vendor_data.otp" placeholder="OTP" />
                            </div>
                        </div>
                        <div class="d-flex text-center justify-content-center py-3">
                            <button class="prev-button" @click.prevent="validateOtp">Verify OTP</button>
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
                            <!-- <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Language: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="text" v-model="vendor_data.personal.language" placeholder="Languages"/>
                                    </div>
                                </div>
                            </div> -->

                            <div class="col-12">
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
                                    <div class="d-flex flex-column col-12">
                                        <b-form-file @input="changeIdentityImage($event)" v-model="vendor_data.personal.identity_proof_file" ref="file-input" class="mb-2"></b-form-file>
                                        <div class="d-flex" v-if="vendor_data.personal.identity_proof_file_url" >
                                            <img :src="vendor_data.personal.identity_proof_file_url" alt="Image" style="width: 100px !important; height: 100px !important; border-radius: 16px !important; object-fit: scale-down !important;">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="w-100" v-if="progress[in_progress_index].name == 'Store'">
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
                                            <b-form-file v-model="vendor_data.store.blank_cheque" ref="file-input" class="mb-2" />
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
                            <div class="d-flex flex-column">
                                <div class="col-12">
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
                                <div class="d-flex flex-row">
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Packing Charges: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input inputmode="numeric" type="number" v-model="vendor_data.store.packing_charges" placeholder="Packing Charges"></b-form-input>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Convenience Fee: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input inputmode="numeric" type="number" v-model="vendor_data.store.conv_fee" placeholder="Packing Charges"></b-form-input>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex flex-row">
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Packing Charges: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-file @input="handleFileUploadForGst($event)" v-model="vendor_data.store.gst_file" ref="file-input" plain class="mb-2"></b-form-file>
                                                <div class="d-flex" v-if="vendor_data.store.gst_file_url" >
                                                    <img :src="vendor_data.store.gst_file_url" alt="Image" style="width: 100px !important; height: 100px !important; border-radius: 16px !important; object-fit: scale-down !important;">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Convenience Fee: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-file @input="handleFileUploadFor($event)" v-model="vendor_data.store.fssai_file" ref="file-input" plain class="mb-2"></b-form-file>
                                                <div class="d-flex" v-if="vendor_data.store.fssai_file_url" >
                                                    <img :src="vendor_data.store.fssai_file_url" alt="Image" style="width: 100px !important; height: 100px !important; border-radius: 16px !important; object-fit: scale-down !important;">
                                                </div>
                                            </div>
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
                                                <b-form-input type="text" v-model="vendor_data.store.country" placeholder="Country" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">State: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" v-model="vendor_data.store.state" placeholder="State" />
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
                                                <b-form-input type="text" v-model="vendor_data.store.city" placeholder="City" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Pincode: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" v-model="vendor_data.store.pincode" placeholder="Pincode" />
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
                                                <b-form-input type="text" v-model="vendor_data.store.area" placeholder="Area" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Street Number / Name: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" v-model="vendor_data.store.add1" placeholder="Street Number / Name" />
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
                                                <b-form-input type="text" v-model="vendor_data.store.add2" placeholder="Door No, Floor, Apartment" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Landmark: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="text" v-model="vendor_data.store.landmark" placeholder="Landmark" />
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
                                                <b-form-input type="number" v-model="vendor_data.store.lat" placeholder="Lattitude" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="d-flex flex-column align-items-left">
                                            <div class="col-12">
                                                <label class="input-label">Longitude: </label>
                                            </div>
                                            <div class="col-12">
                                                <b-form-input type="number" v-model="vendor_data.store.lng" placeholder="Longitude" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="w-100" v-if="progress[in_progress_index].name == 'Bank'">
                    <div class="d-flex flex-column w-100 login-details-area" style="gap: 5px;">
                        <span class="text-center h3">Bank Details</span>
                        <div class="d-flex flex-row">
                            <div class="col-6">
                                    <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Account Holder Name: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="text" v-model="vendor_data.bank.account_holder_name" placeholder="Account Holder Name" />
                                    </div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Account Number: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="text" v-model="vendor_data.bank.account_number" placeholder="Account Number" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row">
                            <div class="col-6">
                                    <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Bank Name: </label>
                                    </div>
                                    <div class="col-12">
                                        <vSelect 
                                            v-model="vendor_data.bank.bank"
                                            :label="'bank_name'"
                                            :options="bank_list"
                                        >
                                        <!-- <template slot="selected-option" slot-scope="option">
                                            <div class="d-flex flex-row justify-content-between">
                                                <img :src="option.image_url" alt="Image" />
                                                <span>{{ option.bank_name }}</span>
                                            </div>
                                        </template>
                                        <template slot="option" slot-scope="option">
                                            <div class="d-flex flex-row">
                                                <img :src="option.image_url" alt="Image" />
                                                <span>{{ option.bank_name }}</span>
                                            </div>
                                        </template> -->
                                    </vSelect>
                                    </div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">City: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="text" v-model="vendor_data.bank.city" placeholder="City" />
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row">
                            <div class="col-6">
                                    <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">Branch: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="text" v-model="vendor_data.bank.branch" placeholder="Branch" />
                                    </div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="d-flex flex-column align-items-left">
                                    <div class="col-12">
                                        <label class="input-label">IFSC Number: </label>
                                    </div>
                                    <div class="col-12">
                                        <b-form-input type="text" v-model="vendor_data.bank.ifsc_code" placeholder="IFSC Number" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
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
    props: ['vendor_data_for_edit', 'type' ],
    components: { vSelect },
    data() {
        return {
            isEdit: false,
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
                    name: 'Bank',
                    completed: false,
                    disable: false
                },
            ],
            categories_list: [],
            services_list: [],
            bank_list: [],
            date: null,
            gender_list: ['MALE', 'FEMALE', 'OTHERS'],
            type_market_place_list: ['PRODUCT', 'SERVICES'],
            delivery_types_list: [],
            identity_proof_list: ['PAN CARD', 'AADHAR CARD', 'VOTER CARD', 'PASSPORT', 'DRIVING LICENSE'],
            created_vendor_id: null,
            vendor_data: {
                profile: {
                    fullname: null,
                    email: null,
                    password: null,
                    confirm_password: null
                },
                verify_otp: false,
                otp_verified: false,
                otp: null,
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
                    identity_proof_file_url: null,
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
                    gst_file: null,
                    fssai_file: null,
                    gst_file_url: null,
                    fssai_file_url: null,
                    store_image: null,
                    packing_charges: 10,
                    conv_fee: 10
                },
                bank: {
                    account_holder_name: null,
                    account_number: null,
                    bank: null,
                    city: null,
                    branch: null,
                    ifsc_code: null
                }
            },
            file: null,
        }
    },
    async mounted() {
        this.loader = true
        await this.fetchCategoryAndServices()
        await this.fetchDeliveryTypesList()
        await this.fetchBanks()
        if (this.vendor_data_for_edit?.id) {
            // console.log(this.vendor_data_for_edit);
            this.placeData()
        } else {
            this.progress = [
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
                    name: 'Bank',
                    completed: false,
                    disable: false
                },
            ]
            this.vendor_data.verify_otp = false
            this.vendor_data.otp_verified = false
        }
        this.loader = false
    },
    methods: {
        handleFileUploadForGst(event) {
            this.vendor_data.store.gst_file_url = URL.createObjectURL(event)
        },
        handleFileUploadFor(event) {
            this.vendor_data.store.fssai_file_url = URL.createObjectURL(event)
        },
        changeIdentityImage(event) {
            this.vendor_data.personal.identity_proof_file_url = URL.createObjectURL(event)
        },
        placeData() {
            // vendor id
            this.created_vendor_id = this.vendor_data_for_edit?.id 
            // vendor personal details 
            this.vendor_data.personal.first_name = this.vendor_data_for_edit ? this.vendor_data_for_edit?.first_name : null
            this.vendor_data.personal.last_name = this.vendor_data_for_edit ? this.vendor_data_for_edit?.last_name : null
            this.vendor_data.personal.dob = this.vendor_data_for_edit ? this.vendor_data_for_edit?.dob : null
            this.vendor_data.personal.gender = this.vendor_data_for_edit?.gender ? this.vendor_data_for_edit?.gender.toUpperCase() : null
            this.vendor_data.personal.email = this.vendor_data_for_edit ? this.vendor_data_for_edit?.personal_email : null
            this.vendor_data.personal.phone = this.vendor_data_for_edit ? this.vendor_data_for_edit?.personal_mobile : null
            this.vendor_data.personal.alt_phone = this.vendor_data_for_edit ? this.vendor_data_for_edit?.personal_alt_mobile : null
            this.vendor_data.personal.country = this.vendor_data_for_edit ? this.vendor_data_for_edit?.country : null
            this.vendor_data.personal.state = this.vendor_data_for_edit ? this.vendor_data_for_edit?.state : null
            this.vendor_data.personal.city = this.vendor_data_for_edit ? this.vendor_data_for_edit?.city : null
            this.vendor_data.personal.area = this.vendor_data_for_edit ? this.vendor_data_for_edit?.area : null
            this.vendor_data.personal.pincode = this.vendor_data_for_edit ? this.vendor_data_for_edit?.pincode : null
            this.vendor_data.personal.add1 = this.vendor_data_for_edit ? this.vendor_data_for_edit?.add1 : null
            this.vendor_data.personal.add2  = this.vendor_data_for_edit ? this.vendor_data_for_edit?.add2 : null
            this.vendor_data.personal.landmark  = this.vendor_data_for_edit ? this.vendor_data_for_edit?.landmark : null
            this.vendor_data.personal.lat  = this.vendor_data_for_edit ? this.vendor_data_for_edit?.lat : null
            this.vendor_data.personal.lng  = this.vendor_data_for_edit ? this.vendor_data_for_edit?.lng : null
            this.vendor_data.personal.identity_proof  = this.vendor_data_for_edit?.identity_proof_name ? this.vendor_data_for_edit?.identity_proof_name?.toUpperCase() : null
            this.vendor_data.personal.identity_proof_file_url  = this.vendor_data_for_edit ? this.vendor_data_for_edit?.identity_proof_file_url : null
            // vendor store details 
            this.vendor_data.store.type_market_place  = this.vendor_data_for_edit?.store?.type_market_place ? this.vendor_data_for_edit?.store?.type_market_place?.toUpperCase() : null
            this.vendor_data.store.selected_product  = this.vendor_data_for_edit?.vendor_product_associations ? this.vendor_data_for_edit?.vendor_product_associations?.map(e => {
                return {
                    id: e.table_id,
                    category_name: e.category_name,
                    table_name: e.table_name
                }
            }) : []
            this.vendor_data.store.store_name  = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.name : null
            this.vendor_data.store.gst_no  = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.gst_number : null
            this.vendor_data.store.fssai_no  = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.fssai_number : null
            this.vendor_data.store.mobile  = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.mobile : null
            this.vendor_data.store.alt_mobile  = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.alt_mobile : null
            this.vendor_data.store.email  = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.email : null
            this.vendor_data.store.delivery_types  = JSON.parse(this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.delivery_types : '[]')
            this.vendor_data.store.country = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.country : null
            this.vendor_data.store.state = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.state : null
            this.vendor_data.store.city = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.city : null
            this.vendor_data.store.area = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.area : null
            this.vendor_data.store.pincode = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.pincode : null
            this.vendor_data.store.add1 = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.add1 : null
            this.vendor_data.store.add2  = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.add2 : null
            this.vendor_data.store.landmark  = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.landmark : null
            this.vendor_data.store.lat  = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.lat : null
            this.vendor_data.store.lng  = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.lng : null
            this.vendor_data.store.packing_charges  = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.packing_charges : null
            this.vendor_data.store.conv_fee  = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.conv_fee : null
            this.vendor_data.store.gst_file_url  = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.gst_file_url : null
            this.vendor_data.store.fssai_file_url  = this.vendor_data_for_edit?.store ? this.vendor_data_for_edit?.store?.fssai_file_url : null

            this.vendor_data.bank.account_holder_name  = this.vendor_data_for_edit?.vendor_bank_detail ? this.vendor_data_for_edit?.vendor_bank_detail?.account_holder_name : null
            this.vendor_data.bank.account_number  = this.vendor_data_for_edit?.vendor_bank_detail ? this.vendor_data_for_edit?.vendor_bank_detail?.account_holder_name : null
            this.vendor_data.bank.bank  = this.vendor_data_for_edit?.vendor_bank_detail ? this.bank_list.find(e => e.id == this.vendor_data_for_edit?.vendor_bank_detail?.bank_id && e.bank_name == this.vendor_data_for_edit?.vendor_bank_detail?.bank_name) : null
            this.vendor_data.bank.city  = this.vendor_data_for_edit?.vendor_bank_detail ? this.vendor_data_for_edit?.vendor_bank_detail?.city : null
            this.vendor_data.bank.branch  = this.vendor_data_for_edit?.vendor_bank_detail ? this.vendor_data_for_edit?.vendor_bank_detail?.branch : null
            this.vendor_data.bank.ifsc_code  = this.vendor_data_for_edit?.vendor_bank_detail ? this.vendor_data_for_edit?.vendor_bank_detail?.ifsc_code : null
            this.isEdit = true
        },
        async goNext() {
            this.loader = true
            switch (this.progress[this.in_progress_index].name) {
                case 'Profile':
                    await this.saveProfileData();
                    break;
                case 'Store':
                    await this.saveStoreDetails();
                    break;
                case 'Bank':
                    await this.saveBankDetails();
                    break;
            
                default:
                    break;
            }
            if (this.in_progress_index + 1 == this.progress.filter(e => e.disable === false).length) {
                // this.$toast.show('This Is The Last Step.', {
                //     duration: 1500,
                //     position: 'top-right',
                //     keepOnHover: true,
                //     type: 'error'
                // })
                this.$emit('closeModal')
            } else {
                this.in_progress_index += 1
                this.progress[this.in_progress_index].completed = true
            }
            this.loader = false
        },
        async saveProfileData() {
            try {
                const createData = {
                    vendor_id: this.created_vendor_id,
                    first_name: this.vendor_data.personal.first_name,
                    last_name: this.vendor_data.personal.last_name,
                    dob: this.vendor_data.personal.dob,
                    gender: this.vendor_data.personal.gender,
                    language: this.vendor_data.personal.language,
                    personal_email: this.vendor_data.personal.email,
                    personal_mobile: this.vendor_data.personal.phone,
                    personal_alt_mobile: this.vendor_data.personal.alt_phone,
                    add1: this.vendor_data.personal.add1,
                    add2: this.vendor_data.personal.add2,
                    area: this.vendor_data.personal.area,
                    city: this.vendor_data.personal.city,
                    country: this.vendor_data.personal.country,
                    state: this.vendor_data.personal.state,
                    pincode: this.vendor_data.personal.pincode,
                    landmark: this.vendor_data.personal.landmark,
                    lat: this.vendor_data.personal.lat,
                    lng: this.vendor_data.personal.lng
                }
                const response = await this.$axios({
                    method: 'post',
                    url: `/vendor-personal-details`,
                    data: createData
                })
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                if (this.vendor_data.personal.identity_proof_file) {
                    const form_data = new FormData()
                    form_data.append('vendor_id', this.created_vendor_id)
                    form_data.append('identity_proof_name', this.vendor_data.personal.identity_proof)
                    form_data.append('identity_proof_file', this.vendor_data.personal.identity_proof_file)
                    const responseIdentity = await this.$axios({
                        method: 'post',
                        url: `/vendor-identity-details`,
                        data: form_data
                    })
                    this.$toast.show(responseIdentity.data.message, {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: responseIdentity.data.status
                    })
                }
            } catch (error) {
                console.log(error);
            }
        },
        async saveStoreDetails() {
            try {
                const create_data = {
                    vendor_id: this.created_vendor_id,
                    name: this.vendor_data.store.store_name,
                    gst_number: this.vendor_data.store.gst_no,
                    fssai_number: this.vendor_data.store.fssai_no,
                    mobile: this.vendor_data.store.mobile,
                    alt_mobile: this.vendor_data.store.alt_mobile,
                    email: this.vendor_data.store.email,
                    add1: this.vendor_data.store.add1,
                    add2: this.vendor_data.store.add2,
                    area: this.vendor_data.store.area,
                    city: this.vendor_data.store.city,
                    state: this.vendor_data.store.state,
                    pincode: this.vendor_data.store.pincode,
                    landmark: this.vendor_data.store.landmark,
                    lat: this.vendor_data.store.lat,
                    lng: this.vendor_data.store.lng,
                    type_market_place: this.vendor_data.store.type_market_place,
                    services: JSON.stringify(this.vendor_data.store.selected_service),
                    country: this.vendor_data.store.country,
                    categories: JSON.stringify(this.vendor_data.store.selected_product),
                    delivery_types: JSON.stringify(this.vendor_data.store.delivery_types),
                    packing_charges: this.vendor_data.store.packing_charges,
                    conv_fee: this.vendor_data.store.conv_fee,
                }
                const response = await this.$axios({
                    method: 'post',
                    url: `/vendor-store-details`,
                    data: create_data
                })
                if (response.data.status == 'success' && (this.vendor_data.store.gst_file || this.vendor_data.store.fssai_file)) {
                    const formData = new FormData()
                    formData.append('vendor_id', this.created_vendor_id) 
                    formData.append('store_id', response.data.data.createdData.id) 
                    formData.append('gst_file', this.vendor_data.store.gst_file) 
                    formData.append('fssai_file', this.vendor_data.store.fssai_file) 
                    const fileUpload = await this.$axios({
                        method: 'post',
                        url: `/store-gst-fssai-files`,
                        data: formData
                    })
                    this.$toast.show(fileUpload.data.message, {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: fileUpload.data.status
                    })
                }
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
            } catch (error) {
                console.log(error);
            }
        },
        async saveBankDetails() {
            try {
                const createData = {
                    vendor_id: this.created_vendor_id,
                    bank_name: this.vendor_data.bank.bank.bank_name,
                    bank_id: this.vendor_data.bank.bank.id,
                    account_holder_name: this.vendor_data.bank.account_holder_name,
                    account_number: this.vendor_data.bank.account_number,
                    city: this.vendor_data.bank.city,
                    branch: this.vendor_data.bank.branch,
                    ifsc_code: this.vendor_data.bank.ifsc_code
                }
                const response = await this.$axios({
                    method: 'post',
                    url: this.isEdit ? '/update-vendor-bank-details' : '/vendor-bank-details',
                    data: createData
                })
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
            } catch (error) {
                console.log(error);
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
        },
        async fetchBanks() {
            try {
                const response = await this.$axios.get('fetch-banks')
                this.bank_list = response.data.bank_list
            } catch (error) {
                console.log(error);
            }
        },
        isValid(text) {
            const emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
            const validEmail = emailRegex.test(text);
            const phoneRegex = /^[1-9]\d{9}$/;
            const validPhone = phoneRegex.test(text);
            return {
                validEmail,
                validPhone
            }
        },
        async validateOtp() {
            try {
                const response = await this.$axios({
                    method: 'post',
                    url: `/validate-otp-customer-vendor?type=VENDOR`,
                    data: {
                        user_id: this.created_vendor_id,
                        otp: this.vendor_data.otp
                    }
                })
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                if (response.data.code == 200) {
                    this.vendor_data.otp_verified = true
                }
            } catch (error) {
                console.log(error);
            }
        },
        async sendOtp() {
            try {
                const { validEmail, validPhone } = this.isValid(this.vendor_data.profile.email)
                if (validPhone) {
                    this.vendor_data.profile.email = `91${this.vendor_data.profile.email}`
                }
                if (validEmail) {
                    this.vendor_data.profile.email = this.vendor_data.profile.email
                }
                const response = await this.$axios({
                    method: 'post',
                    url: '/register-customer-vendor?type=VENDOR', 
                    data: {
                        fullname: this.vendor_data.profile.fullname,
                        username: this.vendor_data.profile.email,
                        password: this.vendor_data.profile.password,
                        confirm_password: this.vendor_data.profile.confirm_password
                    }
                })
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                if (response.data.code == 200) {
                    this.created_vendor_id = response.data.created_user.id
                    this.vendor_data.verify_otp = true
                }
            } catch (error) {
                console.log(error);
            }
        }
    }
}
</script>
