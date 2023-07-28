<template>
    <div class="apartmentHolder">
        <div class="addApartment">
            <div class="p-3 text-center">
                <h3>Filter Units</h3>
                <div class="d-flex flex-column align-items-center">
                    <div class="d-flex align-items-center w-100">
                        <label class="col-6">Apartment:</label>
                        <b-form-select class="col-6 ml-2 my-2" v-model="selectedApartment" @change="selectApartment()" :options="apartmentList" value-field="id" text-field="name"></b-form-select>
                    </div>
                    <div class="d-flex align-items-center w-100">
                        <label class="col-6" v-if="selectedApartment">Floor: </label>
                        <b-form-select class="col-6 ml-2 my-2" v-model="selected_floor" v-if="selectedApartment" :options="floor_list" value-field="value" text-field="text"></b-form-select>
                    </div>
                    <div class="d-flex align-items-center w-100">
                        <label class="col-6" v-if="selectedApartment">BHK: </label>
                        <b-form-select class="col-6 ml-2 my-2" v-model="selected_bhk" v-if="selectedApartment" :options="bhk_list" value-field="value" text-field="text"></b-form-select>
                    </div>
                    <div class="d-flex align-items-center w-100">
                        <label class="col-6" v-if="selectedApartment">Facing: </label>
                        <b-form-select class="col-6 ml-2 my-2" v-model="selected_facing" v-if="selectedApartment" :options="facing_option_list" value-field="value" text-field="text"></b-form-select>
                    </div>
                    <div class="d-flex align-items-center w-100">
                        <label class="col-6" v-if="selectedApartment">Sort By Price: </label>
                        <b-form-select class="col-6 ml-2 my-2" v-model="selected_sort" v-if="selectedApartment" :options="sort_option" value-field="value" text-field="text"></b-form-select>
                    </div>
                    <div class="d-flex align-items-center w-100">
                        <label class="col-6" v-if="selectedApartment">Max Price: </label>
                        <b-form-input class="col-6 ml-2 my-2" v-if="selectedApartment" placeholder="Max Price" v-model="max_price" type="number"></b-form-input>
                    </div>
                    <div class="d-flex align-items-center w-100">
                        <label class="col-6" v-if="selectedApartment">Squarefeet: </label>
                        <b-form-input class="col-6 ml-2 my-2" v-if="selectedApartment" placeholder="Max Squarefeet" v-model="max_sqft" type="number"></b-form-input>
                    </div>
                    <div class="my-2" v-if="selectedApartment">
                        <button class="btn btn-success" @click.prevent="fetchUnits()"><i class="fa fa-filter mr-2"></i>FILTER</button>
                        <button class="btn btn-danger" @click.prevent="resetFilter()"><i class="fa fa-ban mr-2"></i>CLEAR FILTER</button>
                    </div>
                </div>
            </div>
        </div>
        <div class="viewApartment" style="height: 600px; padding: 10px; overflow-y: scroll; width: 60%;">
            <div class="h-100 w-100" v-if="loading">
                <div class="text-center">
                    <b-spinner variant="primary" label="Text Centered"></b-spinner>
                </div>
            </div>
            <div class="card my-2" :class="fetchClass(unit)" style="text-align: center; width: 100%;" v-else-if="!loading && units_list.length > 0" v-for="(unit, index) in units_list" :key="index">
                <div class="card-body">
                    <h5 class="card-title">Unit ID: <b>{{ unit.unit_id }}</b></h5>
                    <p class="card-text" style="margin-top: -10px;"><b>Floor No: </b>{{ unit.floor_no }}</p>
                    <p class="card-text" style="margin-top: -20px;"><b>Facing: </b>{{ unit.facing }}</p>
                    <p class="card-text" style="margin-top: -20px;"><b>Squarefeet: </b>{{ unit.sqft }}</p>
                    <p class="card-text" style="margin-top: -20px;"><b>Super Base Area: </b>{{ unit.sba }}</p>
                    <p class="card-text" style="margin-top: -20px;"><b>Price Per Squarefeet: </b>₹{{ parseFloat(unit.price_per_sqft).toFixed(2) }}</p>
                    <p class="card-text" style="margin-top: -20px;"><b>Total Price: </b>₹{{ parseFloat(parseFloat(unit.price_per_sqft) * parseFloat(unit.sqft)).toFixed(2) }}</p>
                    <p class="card-text" style="margin-top: -20px;"><b>BHK: </b>{{ unit.bhk }}</p>
                    <p class="card-text" style="margin-top: -20px;"><b>Amenities: </b>{{ unit.amenities }}</p>
                    <button class="btn btn-warning" v-if="unit.status != 'BUY'" :disabled="unit.status == 'BOOK' || unit.status == 'BUY'" @click.prevent="bookUnit(unit)"><i class="fa fa-bookmark mr-1"></i>{{unit.status == 'BOOK' ? "BOOKED" : 'BOOK'}}</button>
                    <button class="btn btn-success" @click.prevent="buyUnit(unit)"><i class="fa fa-money mr-1"></i> {{unit.status == 'BUY' ? "BAUGHT" : 'BUY'}}</button>
                    <button v-if="unit.status != 'BUY'" :class="unit.status == 'BOOK' ? 'btn btn-danger' : 'btn btn-primary'" :disabled="unit.status == 'AVAILABLE' || unit.status == 'BUY'" @click.prevent="changeBookingToAvailable(unit)"><i :class="unit.status == 'BOOK' ? 'fa fa-ban mr-1' : 'fa fa-circle-o mr-1'"></i>{{unit.status == 'BOOK' ? "CANCEL BOOKING" : 'AVAILABLE'}}</button>
                </div>
                <b-modal id="BookUnitModal" hide-footer hide-header no-close-on-backdrop>
                    <div>
                        <h3 class="text-center">Book an unit</h3>
                        <div class="d-flex align-items-center w-100 px-2">
                            <label class="col-4" >Unit ID: </label>
                            <b-form-input class="col-8 ml-2 my-2" placeholder="Unit ID" disabled v-model="booking.unit_id" type="text"></b-form-input>
                        </div>
                        <div class="d-flex align-items-center w-100 px-2">
                            <label class="col-4" >Customer: </label>
                            <b-form-select class="col-8 ml-2 my-2" placeholder="Customer" v-model="booking.customer" :options="booking.customer_list" value-field="id" text-field="fullname"></b-form-select>
                        </div>
                        <div class="d-flex align-items-center w-100 px-2">
                            <label class="col-4" >Total Price(₹): </label>
                            <b-form-input type="number" class="col-8 ml-2 my-2" @input="changeTempTotal('book')" placeholder="Total Price" v-model="booking.total_price"></b-form-input>
                        </div>
                        <div class="d-flex align-items-center w-100 px-2">
                            <b-form-checkbox  class="col-4"  @change="changeTotalPrice('book')" v-model="booking.discount_checked">Apply discount</b-form-checkbox> 
                            <b-form-input class="col-8 ml-2 my-2" type="number" placeholder="Discount" @input="changeTotalPrice('book')" :disabled="!booking.discount_checked"  v-model="booking.discount_amount"></b-form-input>
                        </div>
                        <div class="d-flex align-items-center w-100 px-2">
                            <label class="col-4">Booking %: </label>
                            <b-form-input class="col-8 ml-2 my-2" placeholder="Booking Percentage" @input="changeBookingPrice" v-model="booking.booking_amount_perccentage"></b-form-input>
                        </div>
                        <div class="d-flex align-items-center w-100 px-2">
                            <label class="col-4">Book Price(₹): </label>
                            <b-form-input class="col-8 ml-2 my-2" placeholder="Booking Price" disabled v-model="booking.booking_price"></b-form-input>
                        </div>
                        <div class="d-flex align-items-center w-100 px-2">
                            <label class="col-4" >Make Payment: </label>
                            <b-form-checkbox  class="col-8" v-model="booking.make_payment">Pay full amount</b-form-checkbox>
                        </div>
                    </div>
                    <div class="text-center">
                        <button class="btn btn-success mt-3" block @click.prevent="saveUnitToCustomer"><i class="fa fa-bookmark mr-1"></i>BOOK UNIT</button>
                        <button class="btn btn-danger mt-3" block @click.prevent="closeBookModal"><i class="fa fa-ban mr-1"></i>Close</button>
                    </div>
                </b-modal>
                <b-modal id="BuyUnitModal" hide-footer hide-header no-close-on-backdrop>
                    <div>
                        <h3 class="text-center">Buy an unit</h3>
                        <!-- <pre>{{ buying }}</pre> -->
                        <div class="d-flex align-items-center w-100 px-2">
                            <label class="col-4" >Unit ID: </label>
                            <b-form-input class="col-8 ml-2 my-2" placeholder="Unit ID" disabled v-model="buying.unit_id" type="text"></b-form-input>
                        </div>
                        <div class="d-flex align-items-center w-100 px-2">
                            <label class="col-4" >Customer: </label>
                            <b-form-select class="col-8 ml-2 my-2" placeholder="Customer" :disabled="buying.already_booked" v-model="buying.customer" :options="buying.customer_list" value-field="id" text-field="fullname"></b-form-select>
                        </div>
                        <div class="d-flex align-items-center w-100 px-2">
                            <label class="col-4" >Total Price(₹): </label>
                            <b-form-input type="number" class="col-8 ml-2 my-2" @input="changeTempTotal('buy')" placeholder="Total Price" v-model="buying.total_price"></b-form-input>
                        </div>
                        <div class="d-flex align-items-center w-100 px-2">
                            <b-form-checkbox  class="col-4" @change="changeTotalPrice('buy')" v-model="buying.discount_checked">Apply discount</b-form-checkbox> 
                            <b-form-input class="col-8 ml-2 my-2" placeholder="Discount" @input="changeTotalPrice('buy')" :disabled="!buying.discount_checked"  v-model="buying.discount_amount"></b-form-input>
                        </div>
                        <div class="d-flex align-items-center w-100 px-2">
                            <label class="col-4">Remaining Amount (₹): </label>
                            <b-form-input class="col-8 ml-2 my-2" placeholder="Paying Now" disabled v-model="buying.remaining_amount"></b-form-input>
                        </div>
                        <div class="d-flex align-items-center w-100 px-2">
                            <label class="col-4">Paying Now (₹): </label>
                            <b-form-input class="col-8 ml-2 my-2" placeholder="Paying Now" @input="changeRemainingAmount" :disabled="buying.full_payment" v-model="buying.payment_amount"></b-form-input>
                        </div>
                        <div class="d-flex align-items-center w-100 px-2">
                            <label class="col-4" >Make Payment: </label>
                            <b-form-checkbox  class="col-8" @change="payFull" v-model="buying.full_payment">Pay full amount</b-form-checkbox>
                        </div>
                    </div>
                    <div class="text-center">
                        <button class="btn btn-success mt-3" block @click.prevent="buyUnitForCustomer"><i class="fa fa-money mr-1"></i>BUY UNIT</button>
                        <button class="btn btn-danger mt-3" block @click.prevent="closeBuyModal"><i class="fa fa-ban mr-1"></i>Close</button>
                    </div>
                </b-modal>
            </div>
            <div class="class my-2" style="text-align: center; width: 100%;" v-else>
                <div class="card-body">
                    <h5 class="card-title">No units found.</h5>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import Swal from 'sweetalert2'
import { watch } from 'vue'
export default {
    data() {
        return {
            loading: true,
            buying: {
                unit_id: null,
                customer: null,
                customer_list: [],
                total_price: null,
                tempTotalPrice: null,
                already_booked: false,
                discount_checked: false,
                discount_amount: 0,
                payment_amount: 0,
                remaining_amount: 0,
                full_payment: false,
                payments_list: []
            },
            booking: {
                unit_id: null,
                customer: null,
                customer_list: [],
                total_price: null,
                tempTotalPrice: null,
                discount_checked: false,
                discount_amount: 0,
                make_payment: false,
                booking_price: null,
                booking_amount_perccentage: 5,
            },
            apartmentList: [],
            selectedApartment: null,
            selected_floor: null,
            floor_list: [],
            bhk_list: [],
            selected_bhk: null,
            selected_facing: null,
            selected_sort: null,
            max_price: null,
            max_sqft: null,
            sort_option: [
                {
                    value: null,
                    text: 'Select facing direction'
                },
                {
                    value: 'low_to_high',
                    text: 'Low to High'
                },
                {
                    value: 'high_to_low',
                    text: 'High to Low'
                },
            ],
            facing_option_list: [],
            units_list: [],
            customer_role_id: null
        }
    },
    mounted() {
        this.fetchApartments()
        this.fetchUnits()
        this.fetchUserRoleList()
    },
    methods: {
        async buyUnitForCustomer() { 
            if (!this.buying.customer) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Select a customer.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            if (!this.buying.payment_amount) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter the payment amount.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            const payload = {
                unit_id: this.buying.unit_id,
                paid_amount: parseFloat(this.buying.payment_amount).toFixed(2),
                applied_discount: parseFloat(this.buying.discount_amount).toFixed(2),
                total_payable_amount: parseFloat(this.buying.total_price).toFixed(2),
                customer_id: this.buying.customer
            }
            const response = await this.$axios.post('/buy-unit', payload)
            this.$bvModal.hide('BuyUnitModal')
            Swal.fire({
                position: 'top-end',
                icon: response.data.message.includes('success') ? 'success' : 'error',
                title: response.data.message,
                showConfirmButton: false,
                timer: 1500
            })
            this.fetchUnits()
        },
        closeBuyModal() { 
            this.buying = {
                unit_id: null,
                customer: null,
                customer_list: [],
                total_price: null,
                tempTotalPrice: null,
                already_booked: false,
                discount_checked: false,
                discount_amount: 0,
                payment_amount: 0,
                remaining_amount: 0,
                full_payment: false,
                payments_list: []
            }
            this.$bvModal.hide('BuyUnitModal')
        },
        closeBookModal() { 
            this.booking = {
                unit_id: null,
                customer: null,
                customer_list: [],
                total_price: null,
                tempTotalPrice: null,
                discount_checked: false,
                discount_amount: 0,
                make_payment: false,
                booking_price: null,
                booking_amount_perccentage: 5,
            }
            this.$bvModal.hide('BookUnitModal')
        },
        changeTempTotal(type) { 
            switch (type) {
                case 'book':
                    this.booking.tempTotalPrice = this.booking.total_price
                    this.changeBookingPrice()
                    break;
                case 'buy':
                    this.buying.tempTotalPrice = this.buying.total_price
                    this.changeRemainingAmount()
                    break;
            }
        },
        payFull() {
            this.buying.payment_amount = parseFloat(this.buying.total_price).toFixed(2)
            this.changeRemainingAmount()
        },
        changeRemainingAmount() { 
            // this.buying.tempTotalPrice = this.buying.total_price
            this.buying.remaining_amount = parseFloat(parseFloat(this.buying.total_price ? this.buying.total_price : 0) - parseFloat(this.buying.payment_amount ? this.buying.payment_amount : 0)).toFixed(2)
        },
        async buyUnit(unit) {
            this.buying.unit_id = unit.id
            this.buying.customer_list = await this.fetchCustomerList()
            this.buying.payments_list = unit.payments
            this.buying.tempTotalPrice = parseFloat(parseFloat(unit.price_per_sqft) * parseFloat(unit.sqft)).toFixed(2)
            this.buying.total_price = parseFloat(parseFloat(unit.price_per_sqft) * parseFloat(unit.sqft)).toFixed(2)
            if (unit.status == 'BOOK') {
                this.buying.customer = unit.payments.find(e => e.status == true).customer_id
                this.buying.already_booked = true
                this.buying.tempTotalPrice = parseFloat(parseFloat(this.buying.tempTotalPrice) - parseFloat(unit.payments.find(e => e.status == true).paid_amount)).toFixed(2)
                this.buying.total_price = parseFloat(parseFloat(this.buying.tempTotalPrice) - parseFloat(unit.payments.find(e => e.status == true).paid_amount)).toFixed(2)
            }
            this.buying.remaining_amount = parseFloat(parseFloat(this.buying.total_price ? this.buying.total_price : 0) - parseFloat(this.buying.payment_amount ? this.buying.payment_amount : 0)).toFixed(2)
            this.$bvModal.show('BuyUnitModal')
        },
        changeBookingToAvailable(unit) {
            if (unit.status == 'BOOK') {
                Swal.fire({
                    title: 'Are you sure?',
                    text: "You won't be able to revert this!",
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Yes, Cancel booking!'
                }).then(async (result) => {
                    if (result.isConfirmed) {
                        const response = await this.$axios.post('/cancel-booking-unit', {
                            id: unit.id
                        })
                        Swal.fire({
                            position: 'top-end',
                            icon: response.data.message.includes('success') ? 'success' : 'error',
                            title: response.data.message,
                            showConfirmButton: false,
                            timer: 1500
                        })
                        this.fetchUnits()
                    }
                })
            }
        },
        async saveUnitToCustomer() { 
            if (!this.booking.customer) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Select a customer.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            if (!this.booking.make_payment) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Check the "Pay full amount".',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            const response = await this.$axios.post('/book-unit', {
                id: this.booking.unit_id,
                paid_amount: parseFloat(this.booking.booking_price).toFixed(2),
                total_payable_amount: parseFloat(this.booking.total_price).toFixed(2),
                customer_id: this.booking.customer,
                applied_discount: parseFloat(this.booking.discount_amount).toFixed(2),
                book_amount_percentage: parseFloat(this.booking.booking_amount_perccentage).toFixed(2)
            })
            this.$bvModal.hide('BookUnitModal')
            Swal.fire({
                position: 'top-end',
                icon: response.data.message.includes('success') ? 'success' : 'error',
                title: response.data.message,
                showConfirmButton: false,
                timer: 1500
            })
            this.fetchUnits()
        },
        changeTotalPrice(order_type) { 
            switch (order_type) {
                case 'book':
                    if (this.booking.discount_checked) {
                        this.booking.total_price = parseFloat(parseFloat(this.booking.tempTotalPrice) - (parseFloat(parseFloat(this.booking.tempTotalPrice) / 100) * parseFloat(this.booking.discount_amount ? this.booking.discount_amount : 0))).toFixed(2)
                        this.changeBookingPrice()
                    } else {
                        this.booking.discount_amount = 0
                        this.booking.total_price = parseFloat(parseFloat(this.booking.tempTotalPrice) - (parseFloat(parseFloat(this.booking.tempTotalPrice) / 100) * parseFloat(0))).toFixed(2)
                        this.changeBookingPrice()
                    }
                    break;
                case 'buy':
                    if (this.buying.discount_checked) {
                        this.buying.total_price = parseFloat(parseFloat(this.buying.tempTotalPrice) - (parseFloat(parseFloat(this.buying.tempTotalPrice) / 100) * parseFloat(this.buying.discount_amount ? this.buying.discount_amount : 0))).toFixed(2)
                        this.changeRemainingAmount()
                    } else {
                        this.buying.discount_amount = 0
                        this.buying.total_price = parseFloat(parseFloat(this.buying.tempTotalPrice) - (parseFloat(parseFloat(this.buying.tempTotalPrice) / 100) * parseFloat(0))).toFixed(2)
                        this.changeRemainingAmount()
                    }
                    break;
            }
        },
        changeBookingPrice() {
            // this.booking.tempTotalPrice = this.booking.total_price
            this.booking.booking_price = parseFloat((parseFloat(this.booking.total_price ? this.booking.total_price : 0) / 100 ) * parseFloat(this.booking.booking_amount_perccentage ? this.booking.booking_amount_perccentage : 0)).toFixed(2)
        },
        async fetchCustomerList() {
            const response = await this.$axios.get('/get-user-list', {
                params: {
                    user_role_id: this.customer_role_id
                },
            })
            let customerList = response.data.data.customer
            customerList.unshift({
                id: null,
                fullname: 'Select a customer',
            })
            return customerList
        },
        async fetchUserRoleList() {
            const response = await this.$axios.get('/get-user-roles')
            const user_role_list = response.data.data
            this.customer_role_id = user_role_list.find(e => e.role_name == 'CUSTOMER').id           
        },
        async bookUnit(unit) { 
            this.booking.unit_id = unit.id
            this.booking.customer_list = await this.fetchCustomerList()
            this.booking.tempTotalPrice = parseFloat(parseFloat(unit.price_per_sqft) * parseFloat(unit.sqft)).toFixed(2)
            this.booking.total_price = parseFloat(parseFloat(unit.price_per_sqft) * parseFloat(unit.sqft)).toFixed(2)
            this.booking.booking_price = parseFloat((parseFloat(this.booking.total_price) / 100 ) * parseFloat(this.booking.booking_amount_perccentage)).toFixed(2)
            this.$bvModal.show('BookUnitModal')
        },
        fetchClass(unit) { 
            switch (unit.status) {
                case 'AVAILABLE':
                    return 'bg-primary'
                case 'BOOK':
                    return 'bg-warning'
                case 'BUY':
                    return 'bg-success'
            }
        },
        resetFilter() { 
            this.selectedApartment = null
            this.selected_floor = null
            this.max_sqft = null
            this.selected_facing = null
            this.max_price = null
            this.selected_bhk = null
            this.fetchUnits()
        },
        async fetchUnits() {
            this.loading = true
            const params = {
                apt_id: this.selectedApartment,
                floor_no: this.selected_floor,
                sqft: this.max_sqft,
                facing: this.selected_facing,
                price_per_sqft: this.max_price,
                bhk: this.selected_bhk,
            }
            const response = await this.$axios.get('/get-unit-for-sales', {
                params,
            })
            this.units_list = response.data.data
            this.loading = false
        },
        async fetchApartments() {
            const response = await this.$axios.get('/get-apartments')
            this.apartmentList = response.data.data
            this.apartmentList.unshift({
                id: null,
                name: 'Select a apartment',
            })
        },
        async fetchFilters(apt_id) { 
            const response = await this.$axios.get('/get-unit-filters', {
                params: {
                    apt_id
                }
            })
            this.bhk_list = response.data.data.bhk_list.map(e => {
                return {
                    text: `${e.bhk} BHK`,
                    value: e.bhk
                }
            })
            this.bhk_list.unshift({
                value: null,
                text: 'Select the BHK.'
            })
            this.facing_option_list = response.data.data.facing_list.map(e => {
                return {
                    text: `${e.facing} FACING`,
                    value: e.facing
                }
            })
            this.facing_option_list.unshift({
                value: null,
                text: 'Select the facing.'
            })
        },
        async selectApartment() {
            const floors = this.apartmentList.find(e => e.id == this.selectedApartment).floor_no
            this.floor_list = Array.from(Array(floors).keys()).map(e => {
                return {
                    value: e + 1,
                    text: e + 1,
                }
            })
            this.floor_list.unshift({
                value: null,
                text: 'Select the floor.'
            })
            await this.fetchFilters(this.selectedApartment)
        }
    },
}
</script>

<style>
.apartmentHolder {
    width: 100%;
    height: max-content;
    display: flex;
}
.addApartment {
    width: 40%;
    float: left;
}

.viewApartment {
    float: left;
}
.unitDetails {
    width: 30%;
    float: left;
}
</style>