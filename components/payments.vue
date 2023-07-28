<template>
    <div>
        <div class="w-100 row">
            <div class="col-3 d-flex align-items-center py-2 mx-2">
                <label class="mr-2 mt-1">UNIT: </label>
                <b-select v-model="selected_unit" @change="fetchPayments" :options="units_list"></b-select>
            </div>
            <div class="col-3 d-flex align-items-center py-2 mx-2">
                <label class="mr-2 mt-1">CUSTOMER: </label>
                <b-select v-model="selected_customer" @change="fetchPayments" :options="customer_list"></b-select>
            </div>
            <div class="col-3 d-flex align-items-center py-2 mx-2">
                <label class="mr-2 mt-1">STATUS: </label>
                <b-select v-model="selected_status" @change="fetchPayments" :options="status_list"></b-select>
            </div>
        </div>
        <div v-if="loader" class="p-5">
            <div class="text-center p-5" style="border: none;">
                <b-spinner></b-spinner>
            </div>
        </div>
        <div v-else-if="!loader && payment_list.length > 0" class="w-100 p-2">
            <table class="table table-striped">
                <thead style="background: #2c2c2c;">
                    <tr style="font-weight: 700; color: white; text-align: center;">
                        <td>Unit</td>
                        <td>Payment Type</td>
                        <td>Paid Amount</td>
                        <td>Total Price</td>
                        <td>Customer</td>
                        <td>Status</td>
                        <td>Date</td>
                        <td>Action</td>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="(payment, index) in payment_list" :key="index">
                        <td>{{ payment.unit }}</td>
                        <td>{{ payment.payment_type }}</td>
                        <td>{{ payment.paid_amount }}</td>
                        <td>{{ payment.total_price }}</td>
                        <td>{{ payment.customer }}</td>
                        <td>{{ payment.status }}</td>
                        <td>{{ payment.date }}</td>
                        <td style="text-align: center;">
                            <button v-if="payment.remaining_amount > 0" @click.prevent="openRemainingAmountModal(payment)" class="btn btn-outline-success">Pay</button>
                            <span v-else>Fully Paid</span>
                        </td>
                    </tr>
                </tbody>
            </table>
            <b-modal id="PayRemaining" hide-footer hide-header no-close-on-backdrop>
                <div class="text-center">
                    <h3>Pay Remaining Amount</h3>
                    <div class="card p-3">
                        <!-- <pre>{{ remaining_pay }}</pre> -->
                        <div class="row py-2 align-items-center">
                            <div class="col-5">
                                <label>Total Amount: </label>
                            </div>
                            <div class="col-7">
                                <input class="form-control" v-model="remaining_pay.total_amount" disabled type="text">
                            </div>
                        </div>
                        <div class="row py-2 align-items-center">
                            <div class="col-5">
                                <label>Remaining Amount: </label>
                            </div>
                            <div class="col-7">
                                <input class="form-control" v-model="remaining_pay.remaining_amount" disabled type="text">
                            </div>
                        </div>
                        <div class="row py-2 align-items-center">
                            <div class="col-5">
                                <label>Paying Amount: </label>
                            </div>
                            <div class="col-7">
                                <input class="form-control" @input="changeRemainingAmount" v-model="remaining_pay.paying_amount" type="number">
                            </div>
                        </div>
                        <div class="row py-2 align-items-center">
                            <div class="col-12">
                                <b-form-checkbox
                                    id="checkbox-1"
                                    v-model="remaining_pay.payAll"
                                    name="checkbox-1"
                                    @change="changeRemainingAmount"
                                >
                                    Pay Total Amount.
                                </b-form-checkbox>
                            </div>
                        </div>
                    </div>
                    <div class="text-center">
                        <button class="btn btn-success mt-3" block @click.prevent="PayInstallment"><i class="fa fa-money mr-1"></i>PAY</button>
                        <button class="btn btn-danger mt-3" block @click.prevent="closeModal"><i class="fa fa-ban mr-1"></i>Close</button>
                    </div>
                </div>
            </b-modal>
        </div>
        <div v-else class="p-5">
            <h3 class="text-center">No payment records found.</h3>
        </div>
    </div>
</template>

<script>
import Swal from 'sweetalert2'
export default {
    data() {
        return {
            remaining_pay: {
                unit_details: null,
                total_amount: 0,
                remaining_amount: 0,
                main_remaining_pay: 0,
                paying_amount: 0,
                payAll: false
            },
            payment_list: [],
            loader: true,
            units_list: [],
            selected_unit: null,
            customer_role_id: null,
            customer_list: [],
            selected_customer: null,
            status_list: [
                {
                    value: null,
                    text: 'ALL'
                },
                {
                    value: true,
                    text: 'AVAILABE'
                },
                {
                    value: false,
                    text: 'DELETED'
                }
            ],
            selected_status: null
        }
    },
    async mounted() {
        this.loader = true
        await this.fetchPayments()
        await this.fetchUnits()
        await this.fetchUserRoleList()
        await this.fetchCustomerList()
        this.loader = false
    },
    methods: {
        async PayInstallment() { 
            if (this.remaining_pay.paying_amount == 0) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter payment amount.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            this.loader = true
            const payload = {
                unit_id: parseInt(this.remaining_pay.unit_details.unit_id),
                paid_amount: parseFloat(this.remaining_pay.paying_amount).toFixed(2),
                total_payable_amount: parseFloat(this.remaining_pay.total_amount).toFixed(2),
                customer_id: parseInt(this.remaining_pay.unit_details.customer_id),
            }
            const response = await this.$axios.post('/add-payment-instalment', payload)
            this.closeModal()
            await this.fetchPayments()
            await this.fetchUnits()
            await this.fetchUserRoleList()
            await this.fetchCustomerList()
            Swal.fire({
                position: 'top-end',
                icon: response.data.message.includes('success') ? 'success' : 'error',
                title: response.data.message,
                showConfirmButton: false,
                timer: 1500
            })
            this.loader = false
        },
        changeRemainingAmount() { 
            if (this.remaining_pay.payAll) {
                this.remaining_pay.paying_amount = parseFloat(this.remaining_pay.main_remaining_pay).toFixed(2)
                this.remaining_pay.remaining_amount = parseFloat(0).toFixed(2)
                return
            }
            if (this.remaining_pay.paying_amount && this.remaining_pay.paying_amount > 0) {
                this.remaining_pay.remaining_amount = (parseFloat(this.remaining_pay.main_remaining_pay).toFixed()) - this.remaining_pay.paying_amount
            } else {
                this.remaining_pay.remaining_amount = parseFloat(this.remaining_pay.main_remaining_pay).toFixed(2)
            }
        },
        closeModal() { 
            this.remaining_pay = {
                unit_details: null,
                total_amount: 0,
                remaining_amount: 0,
                main_remaining_pay: 0,
                paying_amount: 0,
                payAll: false
            }
            this.$bvModal.hide('PayRemaining')
        },
        openRemainingAmountModal(payment) { 
            this.remaining_pay.unit_details = payment.unit_details
            this.remaining_pay.paying_amount = 0
            this.remaining_pay.main_remaining_pay = parseFloat(payment.remaining_amount).toFixed(2)
            this.remaining_pay.remaining_amount = parseFloat(payment.remaining_amount).toFixed(2)
            this.remaining_pay.total_amount = parseFloat(payment.total_price.replace('₹ ', '')).toFixed(2)
            this.$bvModal.show('PayRemaining')
        },
        async fetchCustomerList() {
            const response = await this.$axios.get('/get-user-list', {
                params: {
                    user_role_id: this.customer_role_id
                },
            })
            this.customer_list = response.data.data.customer.map(e => {
                return {
                    value: e.id,
                    text: e.fullname
                }
            })
            this.customer_list.unshift({
                value: null,
                text: 'All',
            })
        },
        async fetchUserRoleList() {
            const response = await this.$axios.get('/get-user-roles')
            const user_role_list = response.data.data
            this.customer_role_id = user_role_list.find(e => e.role_name == 'CUSTOMER').id           
        },
        async fetchUnits() {
            const response = await this.$axios.get('/get-unit-for-sales')
            this.units_list = response.data.data.map(e => {
                return {
                    value: e.id,
                    text: e.unit_id
                }
            })
            this.units_list.unshift({
                value: null,
                text: 'All'
            })
        },
        async fetchPayments() {
            const params = {
                customer_id: this.selected_customer,
                unit_id: this.selected_unit,
                status: this.selected_status
            }
            const response = await this.$axios.get('/get-payments', {params})
            this.payment_list = response.data.data.map(e => {
                return {
                    unit_details: {...e, remaining_amount: (parseFloat(e.total_payable_amount) - parseFloat(e.paid_amount))},
                    unit: e.unit.unit_id,
                    payment_type: e.payment_type,
                    paid_amount: `₹ ${parseFloat(e.paid_amount).toFixed(2)}`,
                    total_price: `₹ ${parseFloat(e.total_payable_amount).toFixed(2)}`,
                    customer: e.customer.fullname,
                    status: e.status == 1 ? 'AVAILABLE' : 'DELETED',
                    date: new Date(e.createdAt).toLocaleDateString(),
                    remaining_amount: parseFloat(parseFloat(e.total_payable_amount) - parseFloat(e.total_paid_till_now[0].total_paid_till_now)).toFixed(2)
                }
            })
        }
    }
}
</script>

