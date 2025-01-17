import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
    name: 'description',
    standalone: false
})
export class Description implements PipeTransform {
    transform(text: string): string {
        return text ? String(text).replace(/<[^>]+>/gm, "") : "No description available";
    }
}