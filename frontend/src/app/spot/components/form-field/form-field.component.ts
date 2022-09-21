import {
  Component, ContentChild, HostBinding, Input, Optional,
} from '@angular/core';
import { AbstractControl, FormGroupDirective, NgControl } from '@angular/forms';

@Component({
  selector: 'spot-form-field',
  templateUrl: './form-field.component.html',
})
export class SpotFormFieldComponent {
  @HostBinding('class.spot-form-field') className = true;

  @HostBinding('class.spot-form-field_invalid') get errorClassName() {
    return this.showErrorMessage;
  }

  @Input() label = '';

  @Input() noWrapLabel = false;

  @Input() required = false;

  @Input() hidden = false;

  @Input() control?:AbstractControl;

  @Input() helpTextAttribute?:string;

  @Input() helpTextAttributeScope?:string;

  @Input() showValidationErrorOn:'change' | 'blur' | 'submit' | 'never' = 'submit';

  @ContentChild(NgControl) ngControl:NgControl;

  internalID = `spot-form-field-${+new Date()}`;

  get errorsID() {
    return `${this.internalID}-errors`;
  }

  get descriptionID() {
    return `${this.internalID}-description`;
  }

  get describedByID() {
    return this.showErrorMessage ? this.errorsID : this.descriptionID;
  }

  get formControl():AbstractControl|undefined|null {
    return this.ngControl?.control || this.control;
  }

  get showErrorMessage():boolean {
    if (!this.formControl) {
      return false;
    }

    if (this.showValidationErrorOn === 'submit') {
      return this.formControl.invalid && this._formGroupDirective?.submitted;
    } if (this.showValidationErrorOn === 'blur') {
      return this.formControl.invalid && this.formControl.touched;
    } if (this.showValidationErrorOn === 'change') {
      return this.formControl.invalid && this.formControl.dirty;
    }

    return false;
  }

  constructor(
    @Optional() private _formGroupDirective:FormGroupDirective,
  ) {}
}
