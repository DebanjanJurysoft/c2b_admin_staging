<template>
    <div v-if="loader" class="loader">
        <Loader />
    </div>
    <div v-else>
        <div class="d-flex flex-row justify-content-between align-items-center mb-3">
            <span class="text-heading fontSize25" style="padding-left: 0px !important;">Bulk Upload with CSV</span>
            <div class="w50 d-flex flex-row-reverse justify-content-between align-items-center gap10">
                <button class="button w40" @click.prevent="uploadFileOpen"><i class="fa fa-upload mr-2"></i>Upload CSV</button>
                <b-form-file accept=".csv" class="w30" v-if="uploadFile" v-model="file" plain @change="handleFileUpload( $event )"></b-form-file>
                <button class="button w30" @click.prevent="closeUploadSection" v-if="file"><i class="fa fa-ban mr-2"></i>Close</button>
            </div>
        </div>
        <div class="d-flex flex-column" v-if="!parsed">
            <div class="d-flex flex-row align-items-center gap10">
                <b-form-select 
                    class="w30" 
                    v-model="selected_vendor" 
                    :options="vendor_list"
                ></b-form-select>
                <b-form-select 
                    class="w30" 
                    v-if="selected_vendor"
                    v-model="selected_category" 
                    :options="category_list"
                ></b-form-select>
                <b-form-input type="number" class="w20" v-model="number_of_products" v-if="selected_vendor && selected_category" inputmode="numeric" placeholder="Number of products"></b-form-input>
                <button class="button w20" @click="downloadCsv" v-if="selected_vendor && selected_category && number_of_products"><i class="fa fa-save mr-2"></i>Download CSV</button>
            </div>
            <div class="d-flex flex-row p-5 justify-content-center" v-if="selected_vendor && selected_category && number_of_products">
                <span class="text-danger text-heading fontSize30">* Please dont change already added data in CSV file *</span>
            </div>
        </div>
        <div v-else>
            <b-overlay :show="validationLoading" rounded="sm">
                <Table :headings="headers" :data_rows="data_row" />
                <div class="d-flex flex-row justify-content-center py-2">
                    <button class="button" @click.prevent="saveData"><i class="fa fa-save mr-2"></i>Save Data</button>
                </div>
                <template #overlay>
                    <div class="text-center" style="color:  #e74c3c !important;">
                        <p id="cancel-label">Validating Data Please wait...</p>
                    </div>
                </template>
            </b-overlay>
        </div>
    </div>
</template>

<script>
import papaparse from "papaparse";
import Table from "./table.vue"
export default {
    components: { Table },
    data() {
        return {
            savingDataLoader: false,
            validationLoading: false,
            loader: false,
            vendor_list: [],
            selected_vendor: null,
            category_list: [],
            selected_category: null,
            number_of_products: null,
            uploadFile: false,
            foodAdnFoodCourtRequiredFields: [
                'vendor_id',
                'category_id',
                'name',
                'description',
                'total_price',
                'compare_price',
                'gst',
                'food_type',
                'category',
            ],
            file: null,
            data_row: [],
            headers: [],
            parsed: false,
            selectedVendorToUpload: null,
            selectedCategoryToUpload: null,
        }
    },
    watch: {
        selected_vendor(val) {
            if (val) this.fetchCategories()
        }
    },
    mounted() {
        this.mountedFunction()
    }, 
    methods: {
        async saveData() {
            this.savingDataLoader = true
            try {
                const path = '/bulk-upload-food-without-images'
                const data = this.data_row.map(e => {
                    return {
                        name: e.name,
                        description: e.description,
                        total_price: e.total_price,
                        compare_price: e.compare_price,
                        gst: e.gst,
                        food_type: e.food_type
                    }
                })
                const response = await this.$axios.post(path, {
                    food_data: data,
                    vendor_id: this.selectedVendorToUpload,
                    category_id: this.selectedCategoryToUpload
                })
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                this.closeUploadSection()
            } catch (error) {
                console.log(error);
            }
            this.savingDataLoader = false
        },
        closeUploadSection() {
            this.file = null
            this.parsed = false
            this.data_row = []
            this.headers = []
            this.uploadFile = false
            this.$emit('reloadData')
        },
        handleFileUpload( event ){
            this.file = event.target.files[0];
            this.parseFile();
        },
        parseFile(){
            papaparse.parse( this.file, {
                header: true,
                skipEmptyLines: true,
                complete: function( results ){
                    this.data_row = results.data; 
                    this.headers = results.meta.fields.map(e => {
                        return {
                            name: e
                        }
                    }); 
                    this.parsed = true;
                    this.validateFile()
                }.bind(this)
            } );
        },
        async validateFile() {
            this.validationLoading = true
            try {
                let selectedVendor = null
                let mismatchVendor = false
                let selectedCategory = null
                let mismatchCategory = false
                for (const vendor of this.data_row) {
                    if (selectedVendor && selectedVendor != vendor.vendor_id) {
                        mismatchVendor = true
                        break
                    } else if (!selectedVendor) {
                        selectedVendor = vendor.vendor_id
                    }
                    if (selectedCategory && selectedCategory != vendor.category_id) {
                        mismatchCategory = true
                        break
                    } else if (!selectedCategory) {
                        selectedCategory = vendor.category_id
                    }
                }
                if (mismatchVendor) {
                    this.$toast.show('Vendor id has to be same for all the products.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                    this.closeUploadSection()
                }
                if (mismatchCategory) {
                    this.$toast.show('Category id has to be same for all the products.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                    this.closeUploadSection()
                }
                this.selected_vendor = this.vendor_list.find(e => e.value == selectedVendor)?.value
                const category_list_val =  await this.fetchCategoriesForValidation(this.selected_vendor)
                if (this.selected_vendor == null) {
                    this.$toast.show('Vendor id is not valid.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                    this.closeUploadSection()
                } else {
                    this.selected_category = await category_list_val.find(e => e.id == selectedCategory)?.id
                    if (this.selected_category == null) {
                        this.$toast.show('Category id is not valid.', {
                            duration: 1500,
                            position: 'top-right',
                            keepOnHover: true,
                            type: 'error'
                        })
                        this.closeUploadSection()
                    }
                }
                this.selectedCategoryToUpload = this.selected_category
                this.selectedVendorToUpload = this.selected_vendor
                this.selected_category = null
                this.selected_vendor = null
                
            } catch (error) {
                console.log(error);
            }
            this.validationLoading = false
        },
        async uploadFileOpen() {
            this.uploadFile = !this.uploadFile
        },
        async mountedFunction() { 
            try {
                this.loader = true
                await this.fetchVendors()
                this.loader = false
            } catch (error) {
                this.loader = false
                console.log(error);
            }
        },
        async logout() {
            localStorage.removeItem('token')
            // localStorage.removeItem('refreshToken')
            this.$router.push('/login')
        },
        async fetchVendors() {
            try {
                let query = `/approved-vendor`
                const response = await this.$axios.get(query)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.vendor_list = response.data.vendors.map(e => {
                    return {
                        value: e.id,
                        text: e.fullname
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
        async fetchCategories() {
            this.loader = true
            try {
                const path = `/get-categories?vendor_id=${this.selected_vendor}`
                const response = await this.$axios.get(path)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.category_list = response.data.product_types.map(e => {
                    return {
                        value: e.id,
                        text: e.category_name
                    }
                })
                this.category_list.unshift({
                    value: null,
                    text: 'Select a category'
                })
            } catch (error) {
                console.log(error);
            }
            this.loader = false
        },
        async fetchCategoriesForValidation(vend_id) {
            try {
                const path = `/get-categories?vendor_id=${vend_id}`
                const response = await this.$axios.get(path)
                if (response.data.code == 401) {
                    await this.logout()
                }
                return response.data.product_types
            } catch (error) {
                console.log(error);
            }
        },
        async downloadCsv() {
            const selectedVendorData = this.vendor_list.find(e => e.value == this.selected_vendor)
            const selectedCategoryData = this.category_list.find(e => e.value == this.selected_category)
            const headings = this.foodAdnFoodCourtRequiredFields
            const data_list = Array.from(Array(parseInt(this.number_of_products)).keys()).map(e => e + 1).map(el => {
                let data = {}
                this.foodAdnFoodCourtRequiredFields.forEach(e => {
                    if (e == 'vendor_id') {
                        data[e] = this.selected_vendor
                    } else if (e == 'category') {
                        data[e] = selectedCategoryData.text
                    } else if (e == 'category_id') { 
                        data[e] = this.selected_category
                    } else {
                        data[e] = null
                    }
                })
                return data
            })
            const filename = `${selectedVendorData.text.replaceAll(' ','_')}-${this.number_of_products}-products-in-${selectedCategoryData.text.replaceAll(' ','_')}.csv`
            let csv = papaparse.unparse({ data: data_list, fields: headings });
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
        }
    }
}
</script>


<style>
.validation-container {
  position: relative;
  width: 100%;
  height: 100%;
}
.validateloader {
  position: absolute;
  display: flex;
  top: 25%;
  left: 20%;
  right: 0;
  bottom: 0;
  justify-content: center;
  align-items: center;
}
.validationloader {
    color: #e74c3c !important;
}
</style>