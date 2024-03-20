<template>
    <div class="customer-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="d-flex flex-column">
            <div class="d-flex flex-row px-4 py-2 gap10">
                <div class="d-flex flex-column w30">
                    <span class="text-heading" style="padding-left: 0px;">Start Date:</span>
                    <input type="date" v-model="start_date" class="form-control" placeholder="Start Date">
                </div>
                <div class="d-flex flex-column w30">
                    <span class="text-heading" style="padding-left: 0px;">End Date:</span>
                    <input type="date" v-model="end_date" class="form-control" placeholder="End Date">
                </div>
                <div class="d-flex flex-column w10">
                    <span class="text-heading" style="padding-left: 0px;">Set Today:</span>
                    <button class="btn" :class="setToday ? 'btn-primary' : 'btn-success'" @click.prevent="setTodayDate">{{setToday ? 'Last 30 Day' : 'Today' }}</button>
                </div>
                <div class="d-flex flex-column w30">
                    <span class="text-heading" style="padding-left: 0px;">Vendor Name:</span>
                    <b-form-select
                        v-model="selected_vendor"
                        :options="vendor_list"
                    ></b-form-select>
                </div>
            </div>
            <div class="d-flex flex-wrap px-4 py-2 justify-content-around my-5">
                <div class="d-flex flex-row w45 cursor-pointer mb-5" 
                    @mouseleave="() => {
                        report.overlay = false
                    }"
                    @mouseenter="() => {
                        report.overlay = true
                    }" 
                    @click.prevent="report.callBackFunction()" 
                    v-for="(report, report_index) in reports" 
                    :key="report_index"
                >
                    <b-overlay opacity="0.3" :show="report.overlay" class="w100">
                        <template #overlay>
                            <span class="text-heading">Download</span>
                        </template>
                        <div class="sub-category-form border w100 d-flex justify-content-between align-items-center pl-3">
                            <span class="text-heading fontSize35 w90" style="color: black !important; padding-left: 0px;">{{ report.name }}</span>
                            <img class="w10" :src="report.odd_image" style="object-fit: fill;" alt="Report Image">
                        </div>
                    </b-overlay>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import papaparse from "papaparse";
export default {
    data() {
        return {
            loader: false,
            vendor_list: [],
            start_date: null,
            end_date: null,
            setToday: false,
            selected_vendor: null,
            reports: [
                {
                    name: 'Report-1',
                    callBackFunction: this.downloadReportOne,
                    odd_image: '/icons/pie-empty.svg',
                    even_image: '/icons/pie-fill.svg',
                    overlay: false
                },
                {
                    name: 'Vendor Subscription Report',
                    callBackFunction: this.fetchVendorSubscriptionData,
                    odd_image: '/icons/pie-empty.svg',
                    even_image: '/icons/pie-fill.svg',
                    overlay: false
                },
                {
                    name: 'Customer Service Report',
                    callBackFunction: this.fetchServiceReportData,
                    odd_image: '/icons/pie-empty.svg',
                    even_image: '/icons/pie-fill.svg',
                    overlay: false
                },
            ]
        }
    }, 
    async mounted() {
        this.loader = true
        this.start_date = this.formatDate(this.getDateMinus30Days(new Date()))
        this.end_date = this.formatDate(new Date())
        await this.fetchApprovedVendors()
        await this.fetchReportOne()
        this.loader = false
    },
    methods: {
        setTodayDate() {
            if (!this.setToday) {
                this.setToday = true
                this.start_date = this.formatDate(new Date())
                this.end_date = this.formatDate(new Date())
            } else {
                this.setToday = false
                this.start_date = this.formatDate(this.getDateMinus30Days(new Date()))
                this.end_date = this.formatDate(new Date())
            }
        },
        async downloadReportOne() {
            this.loader = true
            const data = await this.fetchReportOne()
            let filename = `report-1`
            if (this.start_date == this.end_date) {
                filename = `${filename}(Today`
            } else {
                filename = `${filename}(From:${this.start_date} - To:${this.end_date}`
            }
            if (this.selected_vendor) {
                const selected_vendor_data = this.vendor_list.find(e => e.value == this.selected_vendor)
                filename = `${filename} For ${selected_vendor_data.text}).csv`
            } else {
                filename = `${filename}).csv`
            }
            let csv = papaparse.unparse({ data: data.data, fields: data.heading });
            if (csv == null) return;
            var blob = new Blob([csv]);
            if (window.navigator.msSaveOrOpenBlob)
                // IE hack; see http://msdn.microsoft.com/en-us/library/ie/hh779016.aspx
                window.navigator.msSaveBlob(blob, args.filename);
            else {
                var a = window.document.createElement("a");
                a.href = window.URL.createObjectURL(blob, { type: "text/plain" });
                a.download = filename;
                document.body.appendChild(a);
                a.click(); // IE: "Access is denied"; see: https://connect.microsoft.com/IE/feedback/details/797361/ie-10-treats-blob-url-as-cross-origin-and-denies-access
                document.body.removeChild(a);
            }
            this.loader = false
        },
        async fetchReportOne() {
            try {
                let path = `/report-1?start_date=${this.start_date}&end_date=${this.end_date}`
                if (this.selected_vendor) {
                    path = `${path}&vendor_id=${this.selected_vendor}`
                }
                const response = await this.$axios.get(path)
                if (response.data.code == 401) {
                    await this.logout()
                }
                const headings = [
                    'Vendor ID',
                    'Vendor Name',
                    'Store ID',
                    'Store Name',
                    'Branch Count',
                    'Approved Products Count',
                    'Rejected Products Count',
                    'Waiting Products Count',
                    'Completed Orders',
                    'Rejected Orders',
                    'ongoing Orders'
                ]
                return {
                    heading: headings,
                    data: response.data.report.map(e => {
                        return {
                            'Vendor ID': e.id,
                            'Vendor Name': e.fullname,
                            'Store ID': e.store.id,
                            'Store Name': e.store.name,
                            'Branch Count': e.branch_count,
                            'Approved Products Count': e.approved_product_count,
                            'Rejected Products Count': e.rejected_product_count,
                            'Waiting Products Count': e.waiting_for_approval_product_count,
                            'Completed Orders': e.completed_orders,
                            'Rejected Orders': e.rejected_orders,
                            'ongoing Orders': e.ongoing_orders
                        }
                    })
                }
            } catch (error) {
                console.log(error);
            }
        },
        isExpired(dateString) {
            const providedDate = new Date(dateString);
            const currentDate = new Date();
            if (providedDate > currentDate) {
                return false;
            } else {
                return true;
            }
        },
        async fetchServiceReportData() {
            try {
                this.loader = true
                const response = await this.$axios.get('/services/fetch-services-subscription-by-customers')
                const data = await response.data.data.map(e => {
                    
                    return {
                        'Service Name': e.service.name,
                        'Customer Name': e.customer.fullname,
                        'Customer E-Mail': e.customer.email ? e.customer.email : 'N/A',
                        'Payment Ref ID': e.payment_ref_id,
                        'Payment Amount': e.payment_amount,
                        'Subscription Type': e.subscription_type,
                        'Is Expired': this.isExpired(e.end_date),
                        'Expiry Date': new Date(e.end_date).toLocaleDateString(),
                    }
                })
                const rows = await Promise.all(data)
                const heading = [
                    'Service Name',
                    'Customer Name',
                    'Customer E-Mail',
                    'Payment Ref ID',
                    'Payment Amount',
                    'Subscription Type',
                    'Is Expired',
                    'Expiry Date',
                ]
                let filename = `CustomerServiceSubscriptionData.csv`
                let csv = papaparse.unparse({ data: rows, fields: heading });
                if (csv == null) return;
                var blob = new Blob([csv]);
                if (window.navigator.msSaveOrOpenBlob)
                    // IE hack; see http://msdn.microsoft.com/en-us/library/ie/hh779016.aspx
                    window.navigator.msSaveBlob(blob, args.filename);
                else {
                    var a = window.document.createElement("a");
                    a.href = window.URL.createObjectURL(blob, { type: "text/plain" });
                    a.download = filename;
                    document.body.appendChild(a);
                    a.click(); // IE: "Access is denied"; see: https://connect.microsoft.com/IE/feedback/details/797361/ie-10-treats-blob-url-as-cross-origin-and-denies-access
                    document.body.removeChild(a);
                }
                this.loader = false
            } catch (error) {
                console.log(error);
            }
        },
        async fetchVendorSubscriptionData() {
            try {
                this.loader = true
                const response = await this.$axios.get('/subscription-report?user_type=VENDOR')
                const data = await response.data.subscriptions.map(e => {
                    var today = new Date();
                    var givenDate = new Date(e.subscription_end_date);
                    var difference = givenDate - today;
                    var daysDifference = Math.ceil(difference / (1000 * 60 * 60 * 24));
                    return {
                        'Vendor Name': `${e.vendor.first_name} ${e.vendor.last_name}`,
                        'Store Name': `${e.store.name}`,
                        'Subscription ID': e.subscription_id,
                        'Plan Name': e.plan.name,
                        'Start Date': e.subscription_start_date,
                        'End Date': e.subscription_end_date,
                        'Days Left': daysDifference,
                    }
                })
                const rows = await Promise.all(data)
                const heading = [
                    'Vendor Name',
                    'Store Name',
                    'Subscription ID',
                    'Plan Name',
                    'Start Date',
                    'End Date',
                    'Days Left',
                ]
                let filename = `VendorSubcriptionData.csv`
                let csv = papaparse.unparse({ data: rows, fields: heading });
                if (csv == null) return;
                var blob = new Blob([csv]);
                if (window.navigator.msSaveOrOpenBlob)
                    // IE hack; see http://msdn.microsoft.com/en-us/library/ie/hh779016.aspx
                    window.navigator.msSaveBlob(blob, args.filename);
                else {
                    var a = window.document.createElement("a");
                    a.href = window.URL.createObjectURL(blob, { type: "text/plain" });
                    a.download = filename;
                    document.body.appendChild(a);
                    a.click(); // IE: "Access is denied"; see: https://connect.microsoft.com/IE/feedback/details/797361/ie-10-treats-blob-url-as-cross-origin-and-denies-access
                    document.body.removeChild(a);
                }
                this.loader = false
            } catch (error) {
                console.log(error);
            }
        },
        formatDate(currentDate) {
            const year = currentDate.getFullYear();
            const month = String(currentDate.getMonth() + 1).padStart(2, '0'); // Months are zero-based
            const day = String(currentDate.getDate()).padStart(2, '0');

            const formattedDate = `${year}-${month}-${day}`;
            return formattedDate
        },
        getDateMinus30Days(currentDate) {
            const thirtyDaysAgo = new Date(currentDate);
            
            // Subtract 30 days
            thirtyDaysAgo.setDate(currentDate.getDate() - 30);
            
            return thirtyDaysAgo;
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
    },
}
</script>