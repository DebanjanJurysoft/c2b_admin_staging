<template>
    <div class="customer-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="tabs-content">
            <div class="d-flex flex-row w-100" style="gap: 30px">
                <div class="d-flex flex-column w50">
                    <div class="d-flex flex-row justify-content-between align-items-center">
                        <span class="text-heading fontSize25">Customer Plans</span>
                        <div class="d-flex flex-row-reverse gap10">
                            <button class="button" @click.prevent="addCustomerPlan('C')"><i class="fa fa-plus mr-2"></i>Add</button>
                        </div>
                    </div>
                    <div class="d-flex flex-column mt-3 border gap16" style="height: 600px; padding: 18px !important; border-radius: 16px !important;">
                        <div class="sub-category-form border" v-if="!customer_plans_list.length">
                            <span class="text-heading">No Record Found</span>
                        </div>
                        <div class="sub-category-form" v-else :style="`background: ${cust_plan.color};`" v-for="(cust_plan, cust_plan_index) in customer_plans_list" :key="cust_plan_index">
                            <!-- <pre>{{ cust_plan }}</pre> -->
                            <template v-if="cust_plan.enable_edit == false">
                                <div class="d-flex flex-row justify-content-between">
                                    <span class="text-heading fontSize20">
                                        <strong>
                                            <strong>Plan Name:</strong>
                                        </strong>
                                        {{ `${cust_plan.name} (${cust_plan.duration_in_days} Days)` }} 
                                    </span>
                                    <div class="d-flex flex-row gap10">
                                        <span @click.prevent="removePlan(cust_plan.id)" class="plan-edit-delete-button plan-button-delete cursor-pointer">
                                            <i class="fa fa-trash"></i>
                                        </span>
                                        <span @click.prevent="openEdit(cust_plan, cust_plan_index)" class="plan-edit-delete-button plan-button-edit cursor-pointer">
                                            <i class="fa fa-pencil"></i>
                                        </span>
                                    </div>
                                </div>
                                <span class="text-heading fontSize18">Benefits: </span>
                                <div class="d-flex flex-row pl-4 my-2" v-for="(cust_plan_benefit, cust_plan_benefit_index) in cust_plan.benefits" :key="cust_plan_benefit_index">
                                    <span class="text-heading" style="padding: 0px !important; width: 10% !important; max-width: 10% !important; min-width: 10% !important; padding-left: 0px !important;">{{ cust_plan_benefit_index + 1 }}.</span>
                                    <span class="text-heading" style="padding: 0px !important; width: 90% !important; max-width: 90% !important; min-width: 90% !important; padding-left: 0px !important;">{{ cust_plan_benefit.text }}</span>
                                </div>
                                <div class="d-flex flex-row gap10">
                                    <div class="w50 d-flex flex-row align-items-center justify-content-center">
                                        <span class="text-heading"><strong class="pr-2"><strong>Price:</strong></strong>{{ `₹ ${cust_plan.price} ${cust_plan.per_month_payment ? '/ Month' : ''}` }}</span>
                                    </div>
                                    <div class="w50 d-flex flex-row" v-if="cust_plan.pay_at_a_time_available">
                                        <span class="text-heading"><strong class="pr-2"><strong>Yearly Price:</strong></strong>{{ `₹ ${cust_plan.pay_at_a_time_price} / Year` }}</span>
                                    </div>
                                </div>
                                <div class="d-flex flex-row justify-content-center gap10">
                                    <div class="d-flex flex-row">
                                        <span class="text-heading"><strong class="pr-2"><strong>GST (%):</strong></strong>{{ `${cust_plan.gst} %` }}</span>
                                    </div>
                                    <div class="d-flex flex-row">
                                        <span class="text-heading"><strong class="pr-2"><strong>Subscribers:</strong></strong>{{ cust_plan.sub_count }}</span>
                                    </div>
                                </div>
                            </template>
                            <template v-if="cust_plan.enable_edit == true">
                                <div class="d-flex flex-row justify-content-between align-items-center">
                                    <span class="text-heading fontSize20 d-flex flex-row align-items-center gap10">
                                        <strong>
                                            <strong>Plan Name:</strong>
                                        </strong>
                                        <b-form-input v-model="cust_plan.name"></b-form-input>
                                    </span>
                                    <div class="d-flex flex-row gap10">
                                        <span @click.prevent="openEdit(cust_plan, cust_plan_index)" class="plan-edit-delete-button plan-button-delete cursor-pointer">
                                            <i class="fa fa-times"></i>
                                        </span>
                                    </div>
                                </div>
                                <span class="text-heading fontSize18">Benefits: </span>
                                <div class="d-flex flex-row pl-4 my-2 align-items-center" v-for="(cust_plan_benefit, cust_plan_benefit_index) in cust_plan.benefits" :key="cust_plan_benefit_index">
                                    <span class="text-heading" style="padding: 0px !important; width: 10% !important; max-width: 10% !important; min-width: 10% !important; padding-left: 0px !important;">{{ cust_plan_benefit_index + 1 }}.</span>
                                    <!-- <span class="text-heading" style="padding: 0px !important; width: 90% !important; max-width: 90% !important; min-width: 90% !important; padding-left: 0px !important;">{{ cust_plan_benefit.text }}</span> -->
                                    <b-form-input style="width: 70% !important; max-width: 70% !important; min-width: 70% !important;" v-model="cust_plan_benefit.text"></b-form-input>
                                    <div class="d-flex flex-row w20 justify-content-center gap8">
                                        <span v-if="cust_plan_benefit_index > 0" @click.prevent="removeFromBenefit(cust_plan_index, cust_plan_benefit_index)" class="plan-edit-delete-button plan-button-delete cursor-pointer sm">
                                            <i class="fa fa-times"></i>
                                        </span>
                                        <span @click.prevent="addToBenefit(cust_plan_index, cust_plan_benefit_index)" class="plan-edit-delete-button plan-button-add cursor-pointer sm">
                                            <i class="fa fa-plus"></i>
                                        </span>
                                    </div>
                                </div>
                                <div class="d-flex flex-row gap10 mt-2">
                                    <div class="w50 d-flex flex-row align-items-center justify-content-center">
                                        <span class="text-heading"><strong><strong>Per Month Payment</strong></strong></span>
                                        <b-checkbox v-model="cust_plan.per_month_payment" switch></b-checkbox>
                                    </div>
                                    <div class="w50 d-flex flex-row align-items-center justify-content-center">
                                        <span class="text-heading w40"><strong class="pr-2"><strong>Price:</strong></strong></span>
                                        <b-form-input class="w60" v-model="cust_plan.price"></b-form-input>
                                    </div>
                                </div>
                                <div class="d-flex flex-row gap10 mt-2">
                                    <div class="w50 d-flex flex-row align-items-center justify-content-center">
                                        <span class="text-heading"><strong><strong>Yearly Payment</strong></strong></span>
                                        <b-checkbox v-model="cust_plan.pay_at_a_time_available" switch></b-checkbox>
                                    </div>
                                    <div class="w50 d-flex flex-row align-items-center justify-content-center">
                                        <span class="text-heading w40"><strong class="pr-2"><strong>Price:</strong></strong></span>
                                        <b-form-input class="w60" v-model="cust_plan.pay_at_a_time_price"></b-form-input>
                                    </div>
                                </div>
                                <div class="d-flex flex-row gap10 mt-2">
                                    <span class="text-heading" style="width: 50% !important; max-width: 50% !important; min-width: 50% !important;"><strong><strong>GST (%)</strong></strong></span>
                                   <b-form-input v-model="cust_plan.gst" placeholder="GST (%)"></b-form-input>
                                </div>
                                <div class="d-flex flex-row gap10 mt-2">
                                    <span class="text-heading" style="width: 50% !important; max-width: 50% !important; min-width: 50% !important;"><strong><strong>Duration In Days</strong></strong></span>
                                   <b-form-input v-model="cust_plan.duration_in_days" placeholder="Duration In Days"></b-form-input>
                                </div>
                                <div class="d-flex flex-row gap10 mt-2">
                                    <span class="text-heading" style="width: 50% !important; max-width: 50% !important; min-width: 50% !important;"><strong><strong>Background Color</strong></strong></span>
                                    <input type="color" v-model="cust_plan.color" class="form-control">
                                </div>
                                <div class="d-flex flex-row gap10 mt-2 justify-content-center">
                                    <button class="button" @click.prevent="savePlan(cust_plan, 'CUSTOMER')"><i class="fa fa-save mr-2"></i>Save</button>
                                </div>
                            </template>
                        </div>
                    </div>
                </div>
                <div class="d-flex flex-column w50">
                    <div class="d-flex flex-row justify-content-between align-items-center">
                        <span class="text-heading fontSize25">Vendor Plans</span>
                        <div class="d-flex flex-row-reverse gap10">
                            <button class="button" @click.prevent="addCustomerPlan('V')"><i class="fa fa-plus mr-2"></i>Add</button>
                        </div>
                    </div>
                    <div class="d-flex flex-column mt-3 border gap16" style="height: 600px; padding: 18px !important; border-radius: 16px !important;">
                        <div class="sub-category-form border" v-if="!vendor_plans_list.length">
                            <span class="text-heading">No Record Found</span>
                        </div>
                        <div class="sub-category-form" v-else :style="`background: ${vend_plan.color};`" v-for="(vend_plan, vend_plan_index) in vendor_plans_list" :key="vend_plan_index">
                            <template v-if="vend_plan.enable_edit == false">
                                <div class="d-flex flex-row justify-content-between">
                                    <span class="text-heading fontSize20">
                                        <strong>
                                            <strong>Plan Name:</strong>
                                        </strong>
                                        {{ `${vend_plan.name} (${vend_plan.duration_in_days} Days)` }} 
                                    </span>
                                    <div class="d-flex flex-row gap10">
                                        <span @click.prevent="removePlan(vend_plan.id)" class="plan-edit-delete-button plan-button-delete cursor-pointer">
                                            <i class="fa fa-trash"></i>
                                        </span>
                                        <span @click.prevent="openEditVend(vend_plan, vend_plan_index)" class="plan-edit-delete-button plan-button-edit cursor-pointer">
                                            <i class="fa fa-pencil"></i>
                                        </span>
                                    </div>
                                </div>
                                <span class="text-heading fontSize18">Benefits: </span>
                                <div class="d-flex flex-row pl-4 my-2" v-for="(vend_plan_benefit, vend_plan_benefit_index) in vend_plan.benefits" :key="vend_plan_benefit_index">
                                    <span class="text-heading" style="padding: 0px !important; width: 10% !important; max-width: 10% !important; min-width: 10% !important; padding-left: 0px !important;">{{ vend_plan_benefit_index + 1 }}.</span>
                                    <span class="text-heading" style="padding: 0px !important; width: 90% !important; max-width: 90% !important; min-width: 90% !important; padding-left: 0px !important;">{{ vend_plan_benefit.text }}</span>
                                </div>
                                <div class="d-flex flex-row gap10">
                                    <div class="w50 d-flex flex-row align-items-center justify-content-center">
                                        <span class="text-heading"><strong class="pr-2"><strong>Price:</strong></strong>{{ `₹ ${vend_plan.price} ${vend_plan.per_month_payment ? '/ Month' : ''}` }}</span>
                                    </div>
                                    <div class="w50 d-flex flex-row" v-if="vend_plan.pay_at_a_time_available">
                                        <span class="text-heading"><strong class="pr-2"><strong>Yearly Price:</strong></strong>{{ `₹ ${vend_plan.pay_at_a_time_price} / Year` }}</span>
                                    </div>
                                </div>
                                
                                <div class="d-flex flex-row justify-content-center gap10">
                                    <div class="d-flex flex-row">
                                        <span class="text-heading"><strong class="pr-2"><strong>GST (%):</strong></strong>{{ `${vend_plan.gst} %` }}</span>
                                    </div>
                                    <div class="d-flex flex-row">
                                        <span class="text-heading"><strong class="pr-2"><strong>Subscribers:</strong></strong>{{ vend_plan.sub_count }}</span>
                                    </div>
                                </div>
                            </template>
                            <template v-if="vend_plan.enable_edit == true">
                                <div class="d-flex flex-row justify-content-between align-items-center">
                                    <span class="text-heading fontSize20 d-flex flex-row align-items-center gap10">
                                        <strong>
                                            <strong>Plan Name:</strong>
                                        </strong>
                                        <b-form-input v-model="vend_plan.name"></b-form-input>
                                    </span>
                                    <div class="d-flex flex-row gap10">
                                        <span @click.prevent="openEditVend(vend_plan, vend_plan_index)" class="plan-edit-delete-button plan-button-delete cursor-pointer">
                                            <i class="fa fa-times"></i>
                                        </span>
                                    </div>
                                </div>
                                <span class="text-heading fontSize18">Benefits: </span>
                                <div class="d-flex flex-row pl-4 my-2 align-items-center" v-for="(vend_plan_benefit, vend_plan_benefit_index) in vend_plan.benefits" :key="vend_plan_benefit_index">
                                    <span class="text-heading" style="padding: 0px !important; width: 10% !important; max-width: 10% !important; min-width: 10% !important; padding-left: 0px !important;">{{ vend_plan_benefit_index + 1 }}.</span>
                                    <!-- <span class="text-heading" style="padding: 0px !important; width: 90% !important; max-width: 90% !important; min-width: 90% !important; padding-left: 0px !important;">{{ vend_plan_benefit.text }}</span> -->
                                    <b-form-input style="width: 70% !important; max-width: 70% !important; min-width: 70% !important;" v-model="vend_plan_benefit.text"></b-form-input>
                                    <div class="d-flex flex-row w20 justify-content-center gap8">
                                        <span v-if="vend_plan_benefit_index > 0" @click.prevent="removeFromBenefit(vend_plan_index, vend_plan_benefit_index, 'V')" class="plan-edit-delete-button plan-button-delete cursor-pointer sm">
                                            <i class="fa fa-times"></i>
                                        </span>
                                        <span @click.prevent="addToBenefit(vend_plan_index, vend_plan_benefit_index, 'V')" class="plan-edit-delete-button plan-button-add cursor-pointer sm">
                                            <i class="fa fa-plus"></i>
                                        </span>
                                    </div>
                                </div>
                                <div class="d-flex flex-row gap10 mt-2">
                                    <div class="w50 d-flex flex-row align-items-center justify-content-center">
                                        <span class="text-heading"><strong><strong>Per Month Payment</strong></strong></span>
                                        <b-checkbox v-model="vend_plan.per_month_payment" switch></b-checkbox>
                                    </div>
                                    <div class="w50 d-flex flex-row align-items-center justify-content-center">
                                        <span class="text-heading w40"><strong class="pr-2"><strong>Price:</strong></strong></span>
                                        <b-form-input class="w60" v-model="vend_plan.price"></b-form-input>
                                    </div>
                                </div>
                                <div class="d-flex flex-row gap10 mt-2">
                                    <div class="w50 d-flex flex-row align-items-center justify-content-center">
                                        <span class="text-heading"><strong><strong>Yearly Payment</strong></strong></span>
                                        <b-checkbox v-model="vend_plan.pay_at_a_time_available" switch></b-checkbox>
                                    </div>
                                    <div class="w50 d-flex flex-row align-items-center justify-content-center">
                                        <span class="text-heading w40"><strong class="pr-2"><strong>Price:</strong></strong></span>
                                        <b-form-input class="w60" v-model="vend_plan.pay_at_a_time_price"></b-form-input>
                                    </div>
                                </div>
                                <div class="d-flex flex-row gap10 mt-2">
                                    <span class="text-heading" style="width: 50% !important; max-width: 50% !important; min-width: 50% !important;"><strong><strong>GST (%)</strong></strong></span>
                                   <b-form-input v-model="vend_plan.gst" placeholder="GST (%)"></b-form-input>
                                </div>
                                <div class="d-flex flex-row gap10 mt-2">
                                    <span class="text-heading" style="width: 50% !important; max-width: 50% !important; min-width: 50% !important;"><strong><strong>Duration In Days</strong></strong></span>
                                   <b-form-input v-model="vend_plan.duration_in_days" placeholder="Duration In Days"></b-form-input>
                                </div>
                                <div class="d-flex flex-row gap10 mt-2">
                                    <span class="text-heading" style="width: 50% !important; max-width: 50% !important; min-width: 50% !important;"><strong><strong>Background Color</strong></strong></span>
                                    <input type="color" v-model="vend_plan.color" class="form-control">
                                </div>
                                <div class="d-flex flex-row gap10 mt-2 justify-content-center">
                                    <button class="button" @click.prevent="savePlan(vend_plan, 'VENDOR')"><i class="fa fa-save mr-2"></i>Save</button>
                                </div>
                            </template>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    data() {
        return {
            loader: false,
            month_list: Array.from(Array(12).keys()).map(e => ({value: e + 1, text: `${e + 1} Months`})),
            customer_plan_edit_id: null,
            vendor_plan_edit_id: null,
            customer_plans_list: [
                // {
                //     id: 1,
                //     name: 'Basic',
                //     price: 100,
                //     enable_edit: false,
                //     per_month_payment: true,
                //     pay_at_a_time_available: true,
                //     pay_at_a_time_price: 1150,
                //     // duration_in_months: 1,
                //     color: "#ffffff",
                //     benefits: [
                //         {
                //             text: 'Benefit 1'
                //         },
                //         {
                //             text: 'Benefit 2'
                //         },
                //         {
                //             text: 'Benefit 3'
                //         },
                //     ]
                // }
            ],
            vendor_plan_edit_id: null,
            vendor_plans_list: [
                // {
                //     id: 2,
                //     name: 'Basic',
                //     price: 100,
                //     enable_edit: false,
                //     per_month_payment: true,
                //     pay_at_a_time_available: false,
                //     pay_at_a_time_price: null,
                //     // duration_in_months: 1,
                //     color: "#4dffb5",
                //     benefits: [
                //         {
                //             text: 'Benefit 1'
                //         },
                //         {
                //             text: 'Benefit 2'
                //         },
                //         {
                //             text: 'Benefit 3'
                //         },
                //     ]
                // }
            ],
        }
    },
    async mounted() { 
        await this.fetchPlans()
    },
    methods: {
        insert(arr, index, newItem) {
            if (index == arr.length - 1) {
                arr.push(newItem);
                return arr
            }
            return [
                // part of the array before the specified index
                ...arr.slice(0, index + 1),
                // inserted item
                newItem,
                // part of the array after the specified index
                ...arr.slice(index + 1)
            ]
        },
        async logout() {
            await this.$auth.logout()
            this.$router.push('/login')
        },
        async fetchPlans() {
            this.loader = true
            try {
                const response = await this.$axios.get('/get-plans')
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.customer_plans_list = response.data.customer_plans.map(e => {
                    return {
                        id: e.id,
                        name: e.name,
                        price: e.price,
                        enable_edit: false,
                        per_month_payment: e.per_month_payment,
                        duration_in_days: e.duration_in_days,
                        gst: e.gst,
                        sub_count: e.plans_subscribers.length,
                        pay_at_a_time_available: e.pay_at_a_time_available,
                        pay_at_a_time_price: e.pay_at_a_time_price,
                        color: e.color,
                        benefits: e.plan_benefits.map(el => ({id: el.id, text: el.benefit})),
                    }
                })
                this.vendor_plans_list = response.data.vendor_plans.map(e => {
                    return {
                        id: e.id,
                        name: e.name,
                        price: e.price,
                        enable_edit: false,
                        per_month_payment: e.per_month_payment,
                        duration_in_days: e.duration_in_days,
                        gst: e.gst,
                        sub_count: e.plans_subscribers.length,
                        pay_at_a_time_available: e.pay_at_a_time_available,
                        pay_at_a_time_price: e.pay_at_a_time_price,
                        color: e.color,
                        benefits: e.plan_benefits.map(el => ({id: el.id, text: el.benefit})),
                    }
                })
            } catch (error) {
                console.log(error);
            }
            this.loader = false
        },
        async savePlan(data, plan_for) { 
            this.loader = true
            const update = plan_for == 'CUSTOMER' ? this.customer_plan_edit_id : this.vendor_plan_edit_id
            try {
                if (data.enable_edit) {
                    delete data.enable_edit
                }
                delete data.id
                const response = await this.$axios({
                    method: 'POST',
                    url: update ? '/update-plan' : '/add-plan',
                    data: update ? {
                        plan_id: update,
                        plan_for,
                        ...data,
                    } : {
                        plan_for,
                        ...data
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
                this.fetchPlans()
            } catch (error) {
                console.log(error);
            }
            this.loader = true
        },
        addCustomerPlan(type = 'C') {
            if (type == 'C') {
                this.customer_plans_list.unshift({
                    id: null,
                    name: null,
                    price: null,
                    enable_edit: true,
                    per_month_payment: false,
                    pay_at_a_time_available: false,
                    pay_at_a_time_price: null,
                    duration_in_days: 28,
                    color: "#ffffff",
                    benefits: [
                        {
                            text: null
                        },
                    ]
                })
            } else if (type == 'V') {
                this.vendor_plans_list.unshift({
                    id: null,
                    name: null,
                    price: null,
                    enable_edit: true,
                    per_month_payment: false,
                    pay_at_a_time_available: false,
                    pay_at_a_time_price: null,
                    duration_in_days: 28,
                    color: "#ffffff",
                    benefits: [
                        {
                            text: null
                        },
                    ]
                })
            }
        },
        async openEdit(cust_plan, cust_index) {
            if (cust_plan.enable_edit) {
                if (cust_plan.id == null) {
                    this.customer_plans_list.splice(cust_index, 1)
                } else {
                    this.loader = true
                    await this.fetchPlans()
                    this.loader = false
                }
                this.customer_plans_list[cust_index].enable_edit = false
                this.customer_plan_edit_id = null
                return
            }
            this.customer_plan_edit_id = cust_plan.id
            this.customer_plans_list[cust_index].enable_edit = true
        },
        async openEditVend(vend_plan, vend_index) {
            if (vend_plan.enable_edit) {
                if (vend_plan.id == null) {
                    this.vendor_plans_list.splice(vend_index, 1)
                } else {
                    this.loader = true
                    await this.fetchPlans()
                    this.loader = false
                }
                this.vendor_plans_list[vend_index].enable_edit = false
                this.vendor_plan_edit_id = null
                return
            }
            this.vendor_plan_edit_id = vend_plan.id
            this.vendor_plans_list[vend_index].enable_edit = true
        },
        addToBenefit(planIndex, benefitIndex, type = 'C') {
            switch (type) {
                case 'C':
                    this.customer_plans_list[planIndex].benefits = this.insert(this.customer_plans_list[planIndex].benefits, benefitIndex, {
                        text: null
                    })
                    break;
                case 'V':
                    this.vendor_plans_list[planIndex].benefits = this.insert(this.vendor_plans_list[planIndex].benefits, benefitIndex, {
                        text: null
                    })
                    break;
            }
        },
        removeFromBenefit(planIndex, benefitIndex, type = 'C') { 
            switch (type) {
                case 'C':
                    this.customer_plans_list[planIndex].benefits.splice(benefitIndex, 1)
                    break;
                    case 'V':
                    this.vendor_plans_list[planIndex].benefits.splice(benefitIndex, 1)
                    break;
            }
        },
        async removePlan(id) {
            this.deleteWithPopup('/remove-plan', 'plan_id', id)
        },
        async deleteWithPopup(path, key, data_id) {
            try {
                const h = this.$createElement
                const id = `DeleteModal${id}`
                this.$bvToast.hide(id)
                const $closeButton = h(
                'b-button',
                {
                    on: { click: () => this.$bvToast.hide(id) },
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
                            await this.fetchPlans()
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
    }
}
</script>

<style>
    .plan-edit-delete-button {
        padding: 8px !important;
        height: 40px !important;
        width: 40px !important;
        display: flex !important;
        justify-content: center !important;
        align-items: center !important;
        border-radius: 50% !important;
        box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px !important;
    }
    .plan-button-delete {
        background: rgb(255, 30, 30) !important;
        color: white !important;
        box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px !important;
    }
    .plan-button-delete:hover {
        box-shadow: rgb(255, 0, 0) 0px 5px 25px !important;
        color: white !important;
    }
    .plan-button-edit {
        background: rgb(34, 108, 255) !important;
        box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px !important;
        color: white !important;
    }
    .plan-button-edit:hover {
        box-shadow: rgb(0, 85, 255) 0px 5px 25px !important;
        color: white !important;
    }
    .plan-button-add {
        background: rgb(41, 255, 34) !important;
        box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px !important;
        color: white !important;
    }
    .plan-button-add:hover {
        box-shadow: rgb(9, 255, 0) 0px 5px 25px !important;
        color: white !important;
    }
    .sm {
        height: 30px !important;
        width: 30px !important;
    }
</style>