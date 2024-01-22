<template>
    <div class="order-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="order-tabs">
            <div class="tab-items" @click.prevent="changeTab(index)" :class="selected_tab.id == tab.id ? 'tab-items-active' : ''" v-for="(tab, index) in tabs" :key="index">
                <span>{{ tab.text }}</span>
            </div>
        </div>
        <div v-if="!loader" class="tabs-content">
            <div class="d-flex flex-row align-items-center">
                <div class="d-flex flex-row align-items-center w85" style="gap: 10px;">
                    <div class="d-flex flex-row">
                        <span class="text-heading" style="padding-left: 0px;">Row</span>
                        <b-form-select style="width: 100px;" v-model="per_page" :options="per_page_options"></b-form-select>
                    </div>
                    <button class="button" @click.prevent="mountedMethod"><i class="fa fa-refresh"></i></button>
                    <div class="d-flex flex-row">
                        <span class="text-heading" style="padding-left: 0px;">Start Date</span>
                        <input type="date" class="form-control" v-model="start_date" style="width: max-content;">
                    </div>
                    <div class="d-flex flex-row">
                        <span class="text-heading" style="padding-left: 0px;">End Date</span>
                        <input type="date" class="form-control" v-model="end_date" style="width: max-content;">
                    </div>
                    <!-- <div class="d-flex flex-row" v-if="selected_tab.id == 1">
                        <span class="text-heading" style="padding-left: 0px;">Cut (%)</span>
                        <b-form-select style="width: 100px;" disabled @change="changeTab(0)" v-model="cut_percentage" :options="cut_percentage_options"></b-form-select>
                    </div> -->
                </div>
                <div class="w15">
                    <!-- top pagination  -->
                    <Pagination @changePage="changePage" :data_list="payments" :per_page="per_page" :total_rows="payment_total" :page="page"/>
                </div>
            </div>
            <div class="d-flex flex-row-reverse align-items-center py-3">
                <div class="d-flex flex-row align-items-center" style="gap: 10px;" v-if="selected_tab.id == 2">
                    <button 
                        class="button" 
                        v-b-tooltip.hover
                        @click.prevent="exportInBankFormat"
                        title="Exprort selected data in bank format."
                    ><i class="fa fa-table mr-2"></i>Export selected data</button>
                    <button 
                        class="button" 
                        v-b-tooltip.hover
                        @click.prevent="openUploadPaymentData"
                        title="Please upload only csv file."
                    ><i class="fa fa-upload mr-2"></i>Upload Paid Data</button>
                </div>
                <div class="d-flex flex-row align-items-center" style="gap: 10px;" v-if="selected_tab.id == 1">
                    <div class="d-flex flex-row" v-if="selected_tab.id == 1">
                        <span class="text-heading" style="padding-left: 0px;">Cut (%)</span>
                        <b-form-select style="width: 100px;" disabled @change="changeTab(0)" v-model="cut_percentage" :options="cut_percentage_options"></b-form-select>
                    </div>
                    <button 
                        class="button" 
                        @click.prevent="exportScreenData"
                        v-b-tooltip.hover
                        title="Please do not change any added data is csv."
                    ><i class="fa fa-table mr-2"></i>Export Visible Data</button>
                    <button 
                        class="button"
                        @click.prevent="exportAllData"
                        v-b-tooltip.hover
                        title="Please do not change any added data is csv."
                    ><i class="fa fa-table mr-2"></i>Export All Data</button>
                </div>
            </div>
            <Table :note="selected_tab.id == 2 ? { text: 'Click on the row to select', class: 'text-danger' } : null" @selectIndexOnClick="selectIndexOnClick" :selected_indexes="selectedIndex" :selectable="selected_tab.id == 2" :style="selected_tab.id == 2 ? 'height: 450px !important;' : ''"  :headings="payment_heading" :data_rows="payments" :page="page" :rows="per_page"/>
            <Pagination @changePage="changePage" :data_list="payments" :per_page="per_page" :total_rows="payment_total" :page="page"/>
            <SidebarComponent @openDetails="openDetails" :visible="show_details" :title="'Product Details'" :product_details="product_details"/>
            <b-modal id="showDataModal" size="xl" hide-footer hide-header no-close-on-backdrop>
                <div class="d-flex flex-row align-items-center justify-content-between">
                    <span class="text-heading fontSize30 pb-4 pr-2" style="padding-left: 0px !important;">Upload paid data form</span>
                    <i class="fa fa-times text-danger pb-4 pr-2 fontSize30 cursor-pointer"  @click.prevent="clearParsedData"></i>
                </div>
                <div class="d-flex flex-column">
                    <div class="d-flex flex-row align-items-center my-3">
                        <b-form-file v-model="selected_file" @change="handleFileUpload( $event )" plain></b-form-file>
                    </div>
                    <b-overlay no-center :show="parsed && data_row.length && validationLoading" rounded="sm">
                        <div style="width: 100% !important; overflow-x: scroll;" v-if="parsed && data_row.length">
                            <table class="main-table">
                                <thead>
                                    <th class="heading"> SL</th>
                                    <th
                                        class="heading"
                                        v-for="(head, head_index) in headers"
                                        :key="head_index"
                                        v-b-tooltip.hover
                                        style="width: max-content !important;"
                                        :title="head.name.replaceAll('_', ' ')"
                                    >
                                        {{ head.name.replaceAll('_', ' ') }}
                                    </th>
                                </thead>
                                <tbody>
                                    <tr
                                        class="table-rows"
                                        v-for="(row, row_index) in data_row"
                                        :key="row_index"
                                    >
                                        <td>
                                            {{ row_index + 1 }}
                                        </td>
                                        <td class="text-center" v-for="(head, head_index) in headers" style="min-width: 200px !important;">
                                            <span v-if="row[head.name] != null && row[head.name] != '' && !['paid_date', 'paid_amount', 'payment_reference_number', 'reason'].includes(head.name)">
                                                {{ row[head.name] }}
                                            </span>
                                            <span v-else-if="head.name.toLowerCase() == 'paid_date' && row.is_input">
                                                <input :disabled="validated" v-model="row[head.name]" style="width: max-content !important;" type="date" class="form-control" />
                                            </span>
                                            <span v-else-if="head.name.toLowerCase() == 'paid_amount' && row.is_input">
                                                <b-form-input :disabled="validated" type="number" v-model="row[head.name]" inputmode="numeric" :placeholder="head.name.replaceAll('_', ' ')"></b-form-input>
                                            </span>
                                            <span v-else-if="head.name.toLowerCase() == 'reason' && row.is_input">
                                                <b-form-input :disabled="validated" type="text" v-model="row[head.name]" :placeholder="head.name.replaceAll('_', ' ')"></b-form-input>
                                            </span>
                                            <span v-else-if="head.name.toLowerCase() == 'payment_reference_number' && row.is_input">
                                                <b-form-input :disabled="validated" v-model="row[head.name]" :placeholder="head.name.replaceAll('_', ' ')"></b-form-input>
                                            </span>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="d-flex flex-row py-3 justify-content-center" style="gap: 10px" v-if="parsed && data_row.length">
                            <button class="button bg-warning" @click.prevent="clearParsedData"><i class="fa fa-ban mr-2"></i>Close</button>
                            <button class="button" @click.prevent="saveData" v-if="validated"><i class="fa fa-save mr-2"></i>Save Data</button>
                            <button class="button" @click.prevent="validateData" v-else><i class="fa fa-check mr-2"></i>Validate Data</button>
                        </div>
                        <template #overlay>
                            <div class="text-center py-5" style="color:  #e74c3c !important;">
                                <p id="cancel-label">Validating Data Please wait...</p>
                            </div>
                        </template>
                    </b-overlay>
                </div>
            </b-modal>
        </div>
    </div>
</template>
<script>
import papaparse from "papaparse";
export default {
    props: ['searchText'],
    data() {
        return {
            cut_percentage_options: Array.from(Array(100).keys()).map(e => {return {value: e+1, text: `${e + 1} %`}}),
            cut_percentage: 2,
            validationLoading: false,
            loader: false,
            selected_file: null,
            selectedIndex: [],
            selected_tab: {
                id: 1,
                name: 'unpaid',
                text: 'unpaid'
            },
            tabs: [
                {
                    id: 1,
                    name: 'unpaid',
                    text: 'unpaid'
                },
                {
                    id: 2,
                    name: 'paid',
                    text: 'paid'
                },
            ],
            start_date: null,
            end_date: this.formatDate(new Date()),
            payments: [],
            payment_heading: [],
            payment_total: 0,
            per_page: 5,
            page: 1,
            per_page_options: Array.from(Array(15).keys()).map(e => e + 1),
            product_details: null,
            show_details: false,
            data_row: [],
            headers: [],
            parsed: false,
            validated: false
        }
    },
    async mounted() {
        this.loader = true
        await this.fetchUnpaid(false)
        await this.fetchUnpaid(true)
        await this.mountedMethod()
        this.changeTab(0)
        this.loader = false
    },
    watch: {
        per_page() {
            this.changePage(this.page)
        },
    },
    methods: {
        async exportInBankFormat() {
            try {
                const data = this.payments.filter((e, i) => this.selectedIndex.includes(i))
                const headings = [
                    'PYMT_PROD_TYPE_CODE',
                    'PYMT_MODE',
                    'DEBIT_ACC_NO',
                    'BNF_NAME',
                    'BENE_ACC_NO',
                    'BENE_IFSC',
                    'AMOUNT',
                    'DEBIT_NARR',
                    'CREDIT_NARR',
                    'MOBILE_NUM',
                    'EMAIL_ID',
                    'REMARK',
                    'PYMT_DATE',
                    'REF_NO',
                    'ADDL_INFO1',
                    'ADDL_INFO2',
                    'ADDL_INFO3',
                    'ADDL_INFO4',
                    'ADDL_INFO5',
                ]
                const csv_data_mapped = data.map(e => {
                    return {
                        PYMT_PROD_TYPE_CODE: e['order ID'],
                        PYMT_MODE: '',
                        DEBIT_ACC_NO: '',
                        BNF_NAME: e['account holder name'],
                        BENE_ACC_NO: e['account name'],
                        BENE_IFSC: e['IFSC code'],
                        AMOUNT: e['paid amount (₹)'],
                        DEBIT_NARR: '',
                        CREDIT_NARR: '',
                        MOBILE_NUM: e['vendor mobile'],
                        EMAIL_ID: e['vendor email'],
                        REMARK: e?.full_data?.payments[0]?.reason || '',
                        PYMT_DATE: new Date(e?.full_data?.payments[0]?.updatedAt).toLocaleDateString() || '',
                        REF_NO: e['payment reference id'],
                        ADDL_INFO1: '',
                        ADDL_INFO2: '',
                        ADDL_INFO3: '',
                        ADDL_INFO4: '',
                        ADDL_INFO5: '',
                    }
                })
                const csv_data = await Promise.all(csv_data_mapped)
                const filename = `selected_payments_in_bank_format.csv`
                let csv = papaparse.unparse({ data: csv_data, fields: headings });
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
            } catch (error) {
                console.log(error);
            }
        },
        selectIndexOnClick(index) {
            if (this.selectedIndex.includes(index)) {
                const indexOfAvl = this.selectedIndex.indexOf(index)
                this.selectedIndex.splice(indexOfAvl)
            } else {
                this.selectedIndex.push(index)
            }
        },
        handleFileUpload(event) {
            this.file = event.target.files[0];
            this.parseFile();
        },
        parseFile() {
            papaparse.parse( this.file, {
                header: true,
                skipEmptyLines: true,
                complete: function( results ){
                    this.data_row = results.data.map(e => {
                        console.log(e);
                        return {
                            ...e,
                            is_input: e.reason != null || e.reason != '' || e.paid_date != null || e.paid_date != '' || e.paid_amount != null || e.paid_amount != '' || e.payment_reference_number != null || e.payment_reference_number != ''
                        }
                    }); 
                    this.headers = results.meta.fields.map(e => {
                        return {
                            name: e
                        }
                    }); 
                    this.parsed = true
                    this.validateData()
                }.bind(this)
            } );
        },
        clearParsedData() {
            this.data_row = []
            this.headers = []
            this.parsed = false
            this.$bvModal.hide('showDataModal')
        },
        async saveData() {
            try {
                this.loader = true
                const response = await this.$axios.post('/pay-all-orders', {
                    payment_data: this.data_row
                })
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                this.clearParsedData()
                await this.fetchUnpaid(false)
                await this.fetchUnpaid(true)
                await this.mountedMethod()
                this.changeTab(1)
                this.loader = false
            } catch (error) {
                console.log(error);
            }
        },
        async validateData() {
            try {
                this.validated = true
                let maxPayableError = false
                let isCorrupt = false
                this.validationLoading = true
                const allPayments = await this.fetchAllPayments()
                for (const data of this.data_row) {
                    const availablePaymentData = allPayments.find(e => e.ord_id == data['order id'])
                    if (availablePaymentData) {
                        let totalDueAmount = Number(availablePaymentData.order_amount)
                        const totalPayable = Number(Number(totalDueAmount) - (Number(Number(this.cut_percentage) / 100) * Number(totalDueAmount)))
                        if (parseFloat(totalDueAmount).toFixed(2) != data['sales amount']) {
                            isCorrupt = true
                        }
                        if (parseFloat(totalPayable).toFixed(2) != data['payable amount']) {
                            isCorrupt = true
                        }
                        if (Number(totalPayable) < Number(data['paid amount (₹)'])) {
                            maxPayableError = true
                            break
                        }
                    }
                    if (!availablePaymentData) {
                        isCorrupt = true
                    }
                    if (!maxPayableError && (data.paid_date == null || data.paid_date == '' || data.payment_reference_number == null || data.payment_reference_number == '')) {
                        this.validated = false
                    }
                }
                if (isCorrupt) {
                    this.$toast.show('Your file is corrupted. please export again and update the data.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                    this.clearParsedData()
                    return
                }
                if (this.validated == false) {
                    this.$toast.show('Some of your data is is left blank. Update in the form.', {
                        duration: 3000,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                }
                if (maxPayableError) {
                    this.$toast.show('Paid amount cannot be more than payable amount.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                    this.validated = false
                }
                this.validationLoading = false
            } catch (error) {
                this.validationLoading = false
                this.clearParsedData()
            }
        },
        openUploadPaymentData() {
            try {
                this.$bvModal.show('showDataModal')
            } catch (error) {
                console.log(error);
            }
        },
        async exportScreenData() {
            try {
                let exportDataHeadings = [
                    'order id',
                    'order_id',
                    'vendor id',
                    'vendor name',
                    'vendor email',
                    'vendor mobile',
                    'vendor alt mobile',
                    'store id',
                    'store name',
                    'bank name',
                    'account holder name',
                    'account number',
                    'IFSC code',
                    'sales amount',
                    'payable amount',
                    'paid_date',
                    'paid_amount',
                    'reason',
                    'payment_reference_number'
                ]
                const exportData = this.payments.map(e => {
                    return {
                        'order id': e['order ID'],
                        'order_id': e['order_id'],
                        'vendor id': e['vendor ID'],
                        'vendor name': e['vendor name'],
                        'vendor email': e['vendor email'],
                        'vendor mobile': e['vendor mobile'],
                        'vendor alt mobile': e['vendor alt mobile'],
                        'store id': e['store ID'],
                        'store name': e['store name'],
                        'bank name': e['bank name'],
                        'account holder name': e['account holder name'],
                        'account number': e['account number'],
                        'IFSC code': e['IFSC code'],
                        'sales amount': e['sales amount (₹)'],
                        'payable amount': e['payable amount (₹)'],
                        'paid_amount': e['payable amount (₹)'],
                    }
                })
                const filename = `unpaid_payments.csv`
                let csv = papaparse.unparse({ data: exportData, fields: exportDataHeadings });
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
            } catch (error) {
                console.log(error);
            }
        },
        async fetchAllPayments() {
            try {
                let query = `/get-unpaid-payments?is_paid=false`
                const response = await this.$axios.get(query)
                if (response.data.code == 401) {
                    await this.logout()
                }
                const paymentData = response.data.payment_details
                return paymentData
            } catch (error) {
                console.log(error);
            }
        },
        async exportAllData() {
            try {
                const response = await this.fetchAllPayments()
                let exportDataHeadings = [
                    'order id',
                    'order_id',
                    'vendor id',
                    'vendor name',
                    'vendor email',
                    'vendor mobile',
                    'vendor alt mobile',
                    'store id',
                    'store name',
                    'bank name',
                    'account holder name',
                    'account number',
                    'IFSC code',
                    'sales amount',
                    'payable amount',
                    'paid_date',
                    'reason',
                    'paid_amount',
                    'payment_reference_number'
                ]
                const data = response.map(payment => {
                    const sales_amount = Number(payment.order_amount)
                    const totalPayable = Number(Number(sales_amount) - (Number(Number(this.cut_percentage) / 100) * Number(sales_amount)))
                    return {
                        'order_id': payment.id,
                        'order ID': payment.ord_id,
                        'store ID': payment.store.id,
                        'vendor ID': payment.vendor.id,
                        'vendor name': payment.vendor.fullname,
                        'vendor email': payment.vendor.personal_email,
                        'vendor mobile': payment.vendor.personal_mobile,
                        'vendor alt mobile': payment.vendor.personal_alt_mobile,
                        'store name': payment.store.name,
                        'bank name': payment.vendor_bank.bank_name,
                        'account holder name': payment.vendor_bank.account_holder_name,
                        'account number': payment.vendor_bank.account_number,
                        'IFSC code': payment.vendor_bank.ifsc_code,
                        'sales amount': parseFloat(sales_amount).toFixed(2),
                        'payable amount': parseFloat(totalPayable).toFixed(2),
                    }
                })
                const exportData = data.map(e => {
                    return {
                        'order id': e['order ID'],
                        'order_id': e['order_id'],
                        'vendor id': e['vendor ID'],
                        'vendor name': e['vendor name'],
                        'vendor email': e['vendor email'],
                        'vendor mobile': e['vendor mobile'],
                        'vendor alt mobile': e['vendor alt mobile'],
                        'store id': e['store ID'],
                        'store name': e['store name'],
                        'bank name': e['bank name'],
                        'account holder name': e['account holder name'],
                        'account number': e['account number'],
                        'IFSC code': e['IFSC code'],
                        'sales amount': e['sales amount'],
                        'payable amount': e['payable amount'],
                        'paid_amount': e['payable amount'],
                    }
                })
                const filename = `all_unpaid_payments.csv`
                let csv = papaparse.unparse({ data: exportData, fields: exportDataHeadings });
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
            } catch (error) {
                console.log(error);
            }
        },
        formatDate(today) {
            const year = today.getFullYear();
            const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are 0-indexed
            const day = String(today.getDate()).padStart(2, '0');
            const formattedDate = `${year}-${month}-${day}`;
            return formattedDate
        },
        async openDetails(data) {
            const index = parseInt(data)
            this.product_details = {}
            if (!this.show_details) {
                const selectedData = this.payments[index]
                this.product_details = {
                    product_image: 'http://localhost:3030/uploads/categories/Food.svg',
                    product_name: selectedData['product name'],
                    product_price: selectedData['unit price'],
                    product_quantity: selectedData.full_data.quantity,
                    product_id: selectedData['product id'],
                    product_desc: selectedData.full_data.product.description,
                    product_colors: selectedData.full_data.product.color ? [{
                        name: selectedData.full_data.product.color,
                    }] : null,
                    product_sizes: selectedData.full_data.product.size ? [{
                        name: selectedData.full_data.product.size[0].toUpperCase()
                    }] : null,
                    product_specification: selectedData.full_data.product.specifications ? selectedData.full_data.product.specifications.split(',') : null,
                    product_negotiation: selectedData.full_data.negotiation ? {
                        heading: 'Negotiation',
                        icon: 'fa fa-commenting-o',
                        text: 'Negotiate for the best deal! Chat with the seller to discuss offers, discounts, and customizations before making your purchase.',
                    } : null,
                    product_delivery_types: [
                        {
                            text: 'SELF PICKUP'
                        },
                        {
                            text: 'DUNZO DELIVERY'
                        },
                        {
                            text: 'SELLER DELIVERY'
                        },
                    ].map(e => {
                        if (e.text == selectedData.full_data.delivery_type.type) {
                            return {
                                value: true,
                                ...e
                            }
                        } else {
                            return {
                                value: false,
                                ...e
                            }
                        }
                    }),
                }
            }
            this.show_details = !this.show_details
        },
        async changePage(page_no) {
            this.page = page_no
            switch (this.selected_tab.id) {
                case 1:
                    await this.fetchUnpaid(false)
                    break;
                case 2:
                    await this.fetchUnpaid(true)
                    break;
            }
            window.scrollTo(0, 0);
            this.loader = false
        },
        async mountedMethod() {
            this.loader = true
            switch (this.selected_tab.id) {
                case 1:
                    await this.fetchUnpaid(false)
                    break;
                case 2:
                    await this.fetchUnpaid(true)
                    break
            }
            this.$emit('reloadDashboard')
            this.loader = false
        },
        async changeTab(index) { 
            this.selected_tab = this.tabs[index]
            this.page = 1
            switch (index) {
                case 0:
                    await this.fetchUnpaid(false)
                    break;
                case 1:
                    await this.fetchUnpaid(true)
                    break
            
                default:
                    break;
            }
            this.loader = false
        },
        async logout() {
            await this.$auth.logout()
            this.$router.push('/login')
        },
        async fetchUnpaid(is_paid) {
            let query = `/get-unpaid-payments?page=${this.page ? this.page : 1}&per_page=${this.per_page}&is_paid=${is_paid}`
            // if (this.searchText && this.searchText != '') {
            //     query = query + `&q=${this.searchText}`
            // }
            const response = await this.$axios.get(query)
            if (response.data.code == 401) {
                await this.logout()
            }
            this.payment_total = response.data.total
            this.payments = response.data.payment_details.map(payment => {
                const sales_amount = Number(payment.order_amount)
                const totalPayable = Number(Number(sales_amount) - (Number(Number(this.cut_percentage) / 100) * Number(sales_amount)))
                return !is_paid ? {
                    'order ID': payment.ord_id,
                    'order_id': payment.id,
                    'store ID': payment.store.id,
                    'vendor ID': payment.vendor.id,
                    'vendor name': payment.vendor.fullname,
                    'vendor email': payment.vendor.personal_email,
                    'vendor mobile': payment.vendor.personal_mobile,
                    'vendor alt mobile': payment.vendor.personal_alt_mobile,
                    'store name': payment.store.name,
                    'bank name': payment.vendor_bank.bank_name,
                    'account holder name': payment.vendor_bank.account_holder_name,
                    'account number': payment.vendor_bank.account_number,
                    'IFSC code': payment.vendor_bank.ifsc_code,
                    'sales amount (₹)': parseFloat(sales_amount).toFixed(2),
                    'payable amount (₹)': parseFloat(totalPayable).toFixed(2),
                    full_data: payment
                } : {
                    'order ID': payment.ord_id,
                    'order_id': payment.id,
                    'store ID': payment.store.id,
                    'vendor ID': payment.vendor.id,
                    'vendor name': payment.vendor.fullname,
                    'vendor email': payment.vendor.personal_email,
                    'vendor mobile': payment.vendor.personal_mobile,
                    'vendor alt mobile': payment.vendor.personal_alt_mobile,
                    'store name': payment.store.name,
                    'bank name': payment.vendor_bank.bank_name,
                    'account holder name': payment.vendor_bank.account_holder_name,
                    'account number': payment.vendor_bank.account_number,
                    'IFSC code': payment.vendor_bank.ifsc_code,
                    'sales amount (₹)': parseFloat(sales_amount).toFixed(2),
                    'paid amount (₹)': parseFloat(totalPayable).toFixed(2),
                    'payment reference id': payment.payments[0].payment_reference,
                    full_data: payment
                }
            })
            if (!is_paid) {
                this.payment_heading = [
                    {
                        name: 'order ID'
                    },
                    {
                        name: 'vendor ID'
                    },
                    {
                        name: 'vendor name'
                    },
                    {
                        name: 'vendor email'
                    },
                    {
                        name: 'vendor mobile'
                    },
                    {
                        name: 'vendor alt mobile'
                    },
                    {
                        name: 'store ID'
                    },
                    {
                        name: 'store name'
                    },
                    {
                        name: 'bank name'
                    },
                    {
                        name: 'account holder name'
                    },
                    {
                        name: 'account number'
                    },
                    {
                        name: 'IFSC code'
                    },
                    {
                        name: 'sales amount (₹)'
                    },
                    {
                        name: 'payable amount (₹)'
                    },
                ]
            } else {
                this.payment_heading = [
                    {
                        name: 'order ID'
                    },
                    {
                        name: 'vendor ID'
                    },
                    {
                        name: 'vendor name'
                    },
                    {
                        name: 'vendor email'
                    },
                    {
                        name: 'vendor mobile'
                    },
                    {
                        name: 'vendor alt mobile'
                    },
                    {
                        name: 'store ID'
                    },
                    {
                        name: 'store name'
                    },
                    {
                        name: 'bank name'
                    },
                    {
                        name: 'account holder name'
                    },
                    {
                        name: 'account number'
                    },
                    {
                        name: 'IFSC code'
                    },
                    {
                        name: 'sales amount (₹)'
                    },
                    {
                        name: 'paid amount (₹)'
                    },
                    {
                        name: 'payment reference id'
                    },
                ]
            }
            this.tabs.forEach(e => {
                if (is_paid === false && e.name == 'unpaid') {
                    e.text = `unpaid (${this.payment_total})`  
                } else if (is_paid === true && e.name == 'paid') {
                    e.text = `paid (${this.payment_total})`  
                }
            })
        },
    }
}
</script>