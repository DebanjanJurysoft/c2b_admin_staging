<template>
    <div class="p-5" style="height: 400px;">
        <input type="file" @change="handleFileUpload($event)" accept=".csv" />
        <div class="py-3 " style="height: 280px;">
            <div v-if="fields.length > 0" v-for="(field, index) in fields" :key="index" class="row align-items-center py-1">
                <h5 class="col-5">{{ field.e }}</h5>
                <i class="col-2 fa fa-arrow-right"></i>
                <b-form-select class="col-5" v-model="field.selected_field" :options="field_list"></b-form-select>
            </div>
        </div>

        <div class="text-center">
            <button class="btn btn-success" @click.prevent="saveData">
                <i class="fa fa-save mr-1"></i>Save Data
            </button>
            <button class="btn btn-primary" @click.prevent="$bvModal.show('preview_data')">
                <i class="fa fa-eye mr-1"></i>Preview Data
            </button>
            <button class="btn btn-danger" @click.prevent="$emit('closeModal')">
                <i class="fa fa-ban mr-1"></i>Close
            </button>
        </div>
        <b-modal id="preview_data" size="xl" hide-footer hide-header no-close-on-backdrop>
            <div class="py-2" v-if="parsed">
                <table class="table table-stripped">
                    <thead>
                        <tr class="text-center" >
                            <td style="font-weight: 700; letter-spacing: 2px;" v-for="(field, i) in fields" :key="i">
                                {{ field.e }} <i v-if=" field.selected_field" class="fa fa-arrow-right"></i> {{ field.selected_field }}
                            </td>
                        </tr>
                    </thead>
                    <tbody>
                        <tr class="text-center" v-for="(result, index) in results" :key="index">
                            <td v-for="(field, ind) in fields" :key="ind">
                                {{ result[field.e] }}
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div v-else class="p-3">
                Please select a file.
            </div>
            <div class="text-center"> 
                <button class="btn btn-danger" @click.prevent="$bvModal.hide('preview_data')">
                    <i class="fa fa-eye-slash mr-1"></i>Close Data Preview
                </button>
            </div>
        </b-modal>
    </div>
</template>

<script>
import Swal from 'sweetalert2'
import Papa from "papaparse";
export default {
    props: ['apartment_details'],
    data() {
        return {
            file: "",
            results: [],
            fields: [],
            required_fields: ['Floor', 'Flat Number', 'Price/sqft'],
            field_list: [
                {
                    value: null,
                    text: 'Select a to field',
                },
                {
                    value: 'floor_no',
                    text: 'floor_no'
                },
                {
                    value: 'unit_id',
                    text: 'unit_id'
                },
                {
                    value: 'sba',
                    text: 'sba'
                },
                {
                    value: 'sqft',
                    text: 'sqft'
                },
                {
                    value: 'price_per_sqft',
                    text: 'price_per_sqft'
                },
            ],
            parsed: false,
        };
    },
    methods: {
        async saveData() { 
            for (let i = 0; i < this.fields.length; i++) {
                if (this.required_fields.includes(this.fields[i].e) && this.fields[i].selected_field == null) {
                    Swal.fire({
                        position: 'top-end',
                        icon: 'error',
                        title: `${this.fields[i].e} field is required. Please select a mapping field.`,
                        showConfirmButton: false,
                        timer: 1500
                    })
                    return
                }
            }
            const mapped_data = this.results.map(elm => {
                let data = {
                    apt_id: this.apartment_details.id
                }
                this.fields.filter(e => e.selected_field).forEach(el => {
                    data[el.selected_field] = el.selected_field == 'unit_id' ? elm[el['e']] : parseFloat(elm[el['e']])
                })
                return data
            })
            const data = await Promise.all(mapped_data)
            let total_units_in_apartment = 0
            this.apartment_details.floors.forEach(e => {
                total_units_in_apartment += e.units
            })
            if (data.length == total_units_in_apartment) {
                const response = this.$axios.post('/bulk-add-unit', {
                   units_data: data
                });
                Swal.fire({
                    position: 'top-end',
                    icon: 'success',
                    title: `unit data saved successfully.`,
                    showConfirmButton: false,
                    timer: 1500
                })
                this.file = null
                this.results = []
                this.parsed = false
                this.fields = []
                this.$emit('closeModal')
            } else {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: `Your apartment data does not match with the csv file.`,
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
        },
        handleFileUpload(event) { 
            this.file = event.target.files[0];
            this.parseFile();
        },
        async parseFile() {
            Papa.parse(this.file, {
                header: true,
                skipEmptyLines: true,
                complete: function (results) {
                    if (results.meta.fields.length == this.field_list.length - 1) {
                        this.results = results.data;
                        this.fields = results.meta.fields.map(e => {
                            return {
                                e,
                                selected_field: null,
                            }
                        })
                        this.parsed = true;
                    } else {
                        Swal.fire({
                            position: 'top-end',
                            icon: 'error',
                            title: 'use a valid csv file with proper data',
                            showConfirmButton: false,
                            timer: 1500
                        })
                    }
                }.bind(this),
            });
        },
    },
};
</script>
