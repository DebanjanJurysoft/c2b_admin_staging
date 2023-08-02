<template>
    <div v-if="loader" style="height: 100vh;">
        <div class="text-center">
            <b-spinner variant="primary" label="Text Centered"></b-spinner>
        </div>
    </div>
    <div v-else >
        <div style="height: 12vh; width: 80vw;  margin-bottom: 2vh; margin-top: -30px; margin-left: -30px;" class="d-flex flex-row-reverse container align-items-center">
            <b-form-select class="select-box" style="width: 20vw;" @change="fetchDashboard" v-model="selected_project" :options="project_list" value-field="id" text-field="project_name"></b-form-select>
        </div>
        <div style="width: 80vw;" class="row">
            <div class="card d-flex flex-row align-items-center" style="width: 31%; margin-right: 15px;  margin-bottom: 2vh; height: 10vh;">
                <img style="width: 15%" src="~/static/flat.png" alt="">
                <div class="d-flex flex-column text-center pt-2" style="width: 85%;" >
                    <h5>Total Projects</h5>
                    <h5 style="color: #027aff;">{{ dashboardData?.projects_count }}</h5>
                </div>
            </div>
            <div class="card d-flex flex-row align-items-center" style="width: 31%; margin-right: 15px; margin-bottom: 2vh; height: 10vh;">
                <img style="width: 15%" src="~/static/flat.png" alt="">
                <div class="d-flex flex-column text-center pt-2" style="width: 85%;" >
                    <h5>Total Blocks</h5>
                    <h5 style="color: #ffc326;">{{ dashboardData?.blocks_count }}</h5>
                </div>
            </div>
            <!-- <div class="card d-flex flex-row align-items-center" style="width: 31%; margin-right: 15px; margin-bottom: 2vh; height: 10vh;">
                <img style="width: 15%" src="~/static/flat.png" alt="">
                <div class="d-flex flex-column text-center pt-2" style="width: 85%;" >
                    <h5>Total Units</h5>
                    <h5 style="color: #6cbd0a;">{{ dashboardData?.units_count }}</h5>
                </div>
            </div> -->
            <div class="card d-flex flex-row align-items-center" style="width: 31%; margin-right: 15px; margin-bottom: 2vh; height: 10vh;">
                <img style="width: 15%" src="~/static/flat.png" alt="">
                <div class="d-flex flex-column text-center pt-2" style="width: 85%;" >
                    <h5>Total Available Units</h5>
                    <h5 style="color: #db34c8;">{{ dashboardData?.available_units_count }}</h5>
                </div>
            </div>
            <div class="card d-flex flex-row align-items-center" style="width: 31%; margin-right: 15px; margin-bottom: 2vh; height: 10vh;">
                <img style="width: 15%" src="~/static/flat.png" alt="">
                <div class="d-flex flex-column text-center pt-2" style="width: 85%;" >
                    <h5>Total Booked Units</h5>
                    <h5 style="color: #027aff;">{{ dashboardData?.booked_units_count }}</h5>
                </div>
            </div>
            <div class="card d-flex flex-row align-items-center" style="width: 31%; margin-right: 15px; margin-bottom: 2vh; height: 10vh;">
                <img style="width: 15%" src="~/static/flat.png" alt="">
                <div class="d-flex flex-column text-center pt-2" style="width: 85%;" >
                    <h5>Total Sold Units</h5>
                    <h5 style="color: #ffc326;">{{ dashboardData?.sold_units_count }}</h5>
                </div>
            </div>
            <div class="card d-flex flex-row align-items-center" style="width: 31%; margin-right: 15px; margin-bottom: 2vh; height: 10vh;">
                <img style="width: 15%" src="~/static/flat.png" alt="">
                <div class="d-flex flex-column text-center pt-2" style="width: 85%;" >
                    <h5>Total Paid</h5>
                    <h5 style="color: #6cbd0a;">{{ dashboardData?.total_paid_amount ? parseFloat(dashboardData?.total_paid_amount).toLocaleString('en-IN', {
                        style: 'currency',
                        currency: 'INR'
                    }) : 0 }}</h5>
                </div>
            </div>
            <div class="card d-flex flex-row align-items-center" style="width: 31%; margin-right: 15px; margin-bottom: 2vh; height: 10vh;">
                <img style="width: 15%" src="~/static/flat.png" alt="">
                <div class="d-flex flex-column text-center pt-2" style="width: 85%;" >
                    <h5>Total Payable</h5>
                    <h5 style="color: #db34c8;">{{ dashboardData?.total_payable_amount ? parseFloat(dashboardData?.total_payable_amount).toLocaleString('en-IN', {
                        style: 'currency',
                        currency: 'INR'
                    }) : 0 }}</h5>
                </div>
            </div>
            <div class="card d-flex flex-row align-items-center" style="width: 31%; margin-right: 15px; margin-bottom: 2vh; height: 10vh;">
                <img style="width: 15%" src="~/static/flat.png" alt="">
                <div class="d-flex flex-column text-center pt-2" style="width: 85%;" >
                    <h5>Total Booked Amount</h5>
                    <h5 style="color: #027aff;">{{ dashboardData?.total_booking_paid_amount ? parseFloat(dashboardData?.total_booking_paid_amount).toLocaleString('en-IN', {
                        style: 'currency',
                        currency: 'INR'
                    }) : 0 }}</h5>
                </div>
            </div>
            <div class="card d-flex flex-row align-items-center" style="width: 31%; margin-right: 15px; margin-bottom: 2vh; height: 10vh;">
                <img style="width: 15%" src="~/static/flat.png" alt="">
                <div class="d-flex flex-column text-center pt-2" style="width: 85%;" >
                    <h5>Total Selleing Amount</h5>
                    <h5 style="color: #ffc326;">{{ dashboardData?.total_sold_paid_amount ? parseFloat(dashboardData?.total_sold_paid_amount).toLocaleString('en-IN', {
                        style: 'currency',
                        currency: 'INR'
                    }) : 0 }}</h5>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="card" style="width: 100%;">
                <div class="d-flex flex-row-reverse" style="width: 100%; justify-content: space-between;">
                    <div>
                        <span :class="selected_option == option ? 'btn2 ml-2' :  'btn3 ml-2'" style="cursor: pointer;"  @click.prevent="changeNotification(option)" v-for="(option, index) in notification_options">{{ option }}</span>
                    </div>
                    <h3 style="color: #027aff;">Notifications</h3>
                </div>
                <div class="row border-bottom border-primary mt-1" style="width: 76vw; border-radius: 20px; padding: 10px;" v-for="(notification, index) in notification_data" :key="index">
                    <div class="col-2 d-flex flex-row-reverse justify-center align-items-center">
                        <i class="fa fa-bell-o" style="color: #ffc326; font-size: 30px;" aria-hidden="true"></i>
                    </div>
                    <div class="col-2 d-flex flex-row-reverse justify-center align-items-center">
                        <span style="font-size: 20px; color: #027aff;">{{ notification.heading }}</span>
                    </div>
                    <div class="col-8 d-flex justify-center align-items-center">
                        <span style="font-size: 20px; color: #027aff;">{{ notification.message }}</span>
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
            dashboardData: {},
            project_list: [],
            selected_project: null,
            notification_options: [
                'booked', 'sold', 'payment'
            ],
            selected_option: 'booked',
            notification_data: []
        }
    },
    async mounted() { 
        this.loader = true
        await this.fetchDashboard()
        this.fetchProjects()
        this.loader = false
    },
    methods: {
        changeNotification(option = null) {
            if (option) {
                this.selected_option = option
            }
            switch (this.selected_option) {
                case 'payment':
                    this.notification_data = this.dashboardData.latest_payment.map(e => {
                        return {
                            heading: e.payment_type,
                            message: `${parseFloat(e.paid_amount).toLocaleString('en-IN', {
                                style: 'currency',
                                currency: 'INR'
                            })}  has been paid for ${e.payment_type} on ${new Date(e.createdAt).toLocaleDateString()}`
                        }
                    })
                    break;
                case 'booked':
                    this.notification_data = this.dashboardData.latest_booked_data.map(e => {
                        return {
                            heading: `Unit: ${e.unit_id}`,
                            message: `${e.apartment.name} - ${e.unit_id} unit has been booked on ${new Date(e.updatedAt).toLocaleDateString()}`
                        }
                    })
                    break;
                case 'sold':
                    this.notification_data = this.dashboardData.latest_sold_data.map(e => {
                        return {
                            heading: `Unit: ${e.unit_id}`,
                            message: `${e.apartment.name} - ${e.unit_id} unit has been sold on ${new Date(e.updatedAt).toLocaleDateString()}`
                        }
                    })
                    break;
            }
        },
        async fetchDashboard() {
            let params = null
            if (this.selected_project) {
                params = {
                    project_id: this.selected_project
                }
            }
            const response = await this.$axios.get('/get-dashboard', {
                params: params
            })
            this.dashboardData = response.data.data
            this.changeNotification()
        },
        async fetchProjects() { 
            try {
                const response = await this.$axios.get('/get-project')
                this.project_list = response.data.data
                this.project_list.unshift({
                    id: null,
                    project_name: 'Select a project'
                })
            } catch (error) {
                console.log(error);
            }
        },
    }
}
</script>