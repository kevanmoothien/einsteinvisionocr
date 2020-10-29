import { LightningElement, api } from 'lwc';


export default class EinsteinResultPreview extends LightningElement {
    @api result

    get columns() {
        let col = []
        if (this.result.task == 'contact') {
            col.push({label: 'Tag', fieldName: 'tag', type: 'text'})
        }
        col.push({label: 'Label', fieldName: 'label', type: 'text'})
        col.push({label: 'Confidence', fieldName: 'probability', type: 'percent', cellAttributes:
        { iconName: { fieldName: 'trendIcon' }, iconPosition: 'right' }})
        if (this.result.task == 'table') {
            col.push({label: 'Row Index', fieldName: 'rowIndex', type: 'text'})
            col.push({label: 'Column Index', fieldName: 'colIndex', type: 'text'})
        }
        return col
    }

    get raw() {
        if (this.result) {
            return JSON.stringify(this.result, null, 2)
        }
        return '{}'
    }

    get data() {
        let payload = []
        if (!this.result) { return }
        this.result['probabilities'].forEach( v => {
            let row = { id: Math.random().toString(36).substr(2, 9),
                        probability: v['probability'],
                        label: v['label'],
                        tag: v['attributes']['tag'],
                        rowIndex: v['attributes']['cellLocation']['rowIndex'],
                        colIndex: v['attributes']['cellLocation']['colIndex'],
                    }
            payload.push(row)
        })

        return payload
    }

    get html () { 
        if (!this.result) { return false }
        if (this.result.task != 'table') { return false }

        let maxCol = 0
        let maxRow = 0
        this.result['probabilities'].forEach( v => {
            maxCol = Math.max(v['attributes']['cellLocation']['colIndex'], maxCol)
            maxRow = Math.max(v['attributes']['cellLocation']['rowIndex'], maxRow)
        })
        let data = []
        for(let x = 0; x < maxRow; x++){ 
            let cols = []
            for(let i = 0; i < maxCol; i++) {
                cols.push('&nbsp;')
            }
            data.push(cols)
        }

        this.result['probabilities'].forEach( v => {
            let row = v['attributes']['cellLocation']['rowIndex']
            let col = v['attributes']['cellLocation']['colIndex']
            data[row-1][col-1] = v['label']
        })

        let h = '<table border="1" style="border-collapse: collapse">'
        for(let x = 0; x < maxRow; x++){ 
            h += '<tr>'
            for(let i = 0; i < maxCol; i++) {
                h += '<td>' + data[x][i] + '</td>'
            }
            h += '</tr>'
        }
        h += '</table>'
        return h
    }
}