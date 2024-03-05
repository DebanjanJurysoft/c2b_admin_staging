<template>
    <div>
        <div class="d-flex justify-content-center">
            <b-form-file class="w-50" v-model="file" @change="handleFileUpload($event)"></b-form-file>
        </div>
        <div v-if="parsed">
            <table class="main-table">
                <thead>
                    <th class="heading" v-for="(head, head_index) in headers" :key="head_index">{{ head.name }}</th>
                </thead>
                <tbody>
                    <tr v-for="(row, row_index) in data_row" :key="row_index" class="table-rows">
                        <td v-for="(head2, head_index2) in headers" :key="head_index2">{{ row[head2.name] }}</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</template>

<script>
import papaparse from "papaparse";
export default {
    data() {
        return {
            default_headings: [
                'SERVICE NAME',
                'PER DAY PRICE',
                'PER MONTH PRICE'
            ],
            uploadFile: false,
            file: null,
            data_row: [],
            headers: [],
            parsed: false,
        }
    },
    methods: {
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
            let allMandatoryHeadersAvailable = false
            this.default_headings.forEach(e => {
                if (!this.headers.find(e => e.name == e)) {
                    allMandatoryHeadersAvailable = false
                }
            })
            if (allMandatoryHeadersAvailable) {
                this.$toast.show('Upload a valid file. try downloading using download button.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                this.data_row = null
                this.headers = null
                this.parsed = false
            } else {
                const data = this.data_row.map(e => {
                    return {
                        name: e['SERVICE NAME'],
                        per_day_price: e['PER DAY PRICE'],
                        per_month_price: e['PER MONTH PRICE']
                    }
                })
                const mapped_data = await Promise.all(data)
                this.$emit('setData', mapped_data)
            }
        },
    },
}
</script>