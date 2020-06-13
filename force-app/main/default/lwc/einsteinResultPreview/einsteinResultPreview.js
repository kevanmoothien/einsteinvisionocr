import { LightningElement, api } from 'lwc';


export default class EinsteinResultPreview extends LightningElement {
    columns = [
        {label: 'Tag', fieldName: 'tag', type: 'text'},
        {label: 'Label', fieldName: 'label', type: 'text'},
        {label: 'Confidence', fieldName: 'probability', type: 'percent', cellAttributes:
            { iconName: { fieldName: 'trendIcon' }, iconPosition: 'right' }}
    ]
    @api result

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
                        tag: v['attributes']['tag']
                    }
            payload.push(row)
        })

        return payload
    }

}