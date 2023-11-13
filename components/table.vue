<template>
  <div class="table-container" v-if="data_rows.length > 0">
    <table class="main-table">
      <thead>
        <th class="heading">
          <i
            class="fa fa-ellipsis-v"
            aria-hidden="true"
            v-b-tooltip.hover
            title="Serial No"
          ></i
          >SL
        </th>
        <th
          class="heading"
          v-for="(head, head_index) in headings"
          :key="head_index"
          v-b-tooltip.hover
          :title="head.name"
        >
          <!-- <i v-if="head.icon" :class="head.icon"></i> -->
          {{ head.name }}
        </th>
      </thead>
      <tbody>
        <tr
          class="table-rows"
          v-for="(row, row_index) in data_rows"
          :key="row_index"
        >
          <td @click.prevent="onClickOpenDetails(row_index)">
            {{ (Number(rows || 0) * (Number(page || 1) - 1)) + row_index + 1 }}
          </td>
          <template v-for="(head, head_index) in headings">
            <td v-if="head.type" style="max-width: max-content !important; min-width: max-content !important; width: max-content !important; text-overflow: clip !important; ">
              <img
                v-if="head.type == 'IMAGE' && row[head.name] != 'N/A'"
                style="height: 30px !important; width: 130px !important; object-fit: cover !important;"
                :src="row[head.name]"
                alt="image"
              />
              <a
                v-else-if="head.type == 'FILE' && row[head.name] != 'N/A'"
                :href="row[head.name]"
              ></a>
              <div v-else-if="head.type == 'SWITCH' && row[head.name] != 'N/A'" class="d-flex flex-row justify-content-center">
                <b-form-checkbox  
                  @change="
                    head.onclick && !head.onclick_emit
                    ? onClickOpenDetails(row_index)
                    : head.onclick_emit
                    ? onClickOpen(row_index, head, row)
                    : ''
                  " 
                  v-model="row[head.name]" switch></b-form-checkbox>
              </div>
                <b-form-select 
                  @change="
                    head.onclick && !head.onclick_emit
                    ? onClickOpenDetails(row_index)
                    : head.onclick_emit
                    ? onClickOpen(row_index, head, row)
                    : ''
                  " 
                  v-else-if="head.type == 'DROPDOWN'" 
                  style="max-width: max-content !important; min-width: max-content !important; width: max-content !important;" 
                  v-model="row[head.name]" 
                  :placeholder="head.name" 
                  :options="head.dropdown_data"
                ></b-form-select>
                <span v-else>N/A</span>
            </td>
            <td
              :style="head.onclick ? 'cursor: pointer;' : ''"
              @click.prevent="
                head.onclick && !head.onclick_emit
                  ? onClickOpenDetails(row_index)
                  : head.onclick_emit
                  ? onClickOpen(row_index, head)
                  : ''
              "
              :key="head_index"
              v-if="head.name != 'action' && !head.type"
              v-b-tooltip.hover
              :title="row[head.name]"
            >
              {{ row[head.name] }}
            </td>
            <td v-if="head.name == 'action'" class="d-flex flex-row" style="width: max-content !important; max-width: max-content !important; gap: 16px;">
              <template v-for="(buttons, action_button_index) in head.buttons">
                <i
                  v-b-tooltip.hover
                  :title="
                    buttons.emit_name.charAt(0).toUpperCase() +
                    buttons.emit_name.slice(1)
                  "
                  @click.prevent="emitData(buttons.emit_name, row)"
                  v-if="!buttons.text"
                  class="px-1"
                  :style="`color: ${buttons.color}; cursor: pointer;`"
                  :key="action_button_index"
                  :class="buttons.icon"
                ></i>
                <b-button
                  v-b-tooltip.hover
                  :title="
                    buttons.emit_name.charAt(0).toUpperCase() +
                    buttons.emit_name.slice(1)
                  "
                  v-if="buttons.text"
                  @click.prevent="emitData(buttons.emit_name, row)"
                  :style="`background: ${buttons.color} !important; color: #fff; cursor: pointer; border: ${buttons.border} !important;`"
                  ><i v-if="buttons.icon" :class="buttons.icon" class="mr-2"></i
                  >{{ buttons.text }}</b-button
                >
              </template>
            </td>
          </template>
        </tr>
      </tbody>
    </table>
    <button class="button float-left mb-3" v-if="file_name" @click.prevent="downloadReport">
      <i class="fa fa-pie-chart mr-2"></i>Report
    </button>
  </div>
  <div class="table-container" v-else>
    <h3 class="w-100 text-center my-5">No records found</h3>
  </div>
</template>

<script>
import papaparse from "papaparse";
export default {
  props: ["headings", "data_rows", "file_name", 'page', 'rows'],
  methods: {
    emitData(emitMethod, data) {
      this.$emit("callFunction", {
        emitMethod,
        data,
      });
    },
    onClickOpenDetails(row_index) {
      this.$emit("openDetails", `${row_index}`);
    },
    onClickOpen(row_index, head, data = null) {
      this.$emit("openSpecific", data  ? {
        row_index,
        type: head.onclick_emit,
        data: data
      } : {
        row_index,
        type: head.onclick_emit,
      });
    },
    async downloadReport() {
      await this.downloadCSV({
        filename: this.file_name,
        data: this.data_rows.map((e) => {
          let temp = e;
          if (temp.full_data) {
            delete temp.full_data;
          }
        let data = {}
            Object.keys(temp).forEach((e) => {
            data[e] = ""+temp[e];
          });
          return data;
        }),
        columns: this.headings
          .filter((e) => e.name != "action")
          .map((e) => e.name),
      });
    },
    async downloadCSV(args) {
      let filename = args.filename || "export.csv";
      let columns = args.columns || null;

      let csv = papaparse.unparse({ data: args.data, fields: columns });
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
    },
  },
};
</script>
