/*
    ============ VERSION ONE NOTICE ============
    Author:Jim Robson http://www.robsondesign.com/blog/
    Copyright (c) 2007 Eye Street Software Corporation - http://www.eyestreet.com
    
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
    and associated documentation files (the "Software"), to deal in the Software without restriction, 
    including without limitation the rights to use, copy, modify, merge, publish, distribute, 
    sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all copies or 
    substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
    NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    ========== end version one notice ==========

    ============ VERSION TWO NOTICE ============
    Version Two created December 2008 by Jim Robson http://www.robsondesign.com/blog/
    
    Changes from Version One: 
    1. Fixed bug in constructor that could cause pre-existing checkbox states to be 
        stored incorrectly in certain circumstances.
    2. Fixed bug in selectSome() method that could cause the other/none of the above checkbox  
        to remain selected even when another checkbox had been selected. 
    3. Fixed bug in selectNone() that could allow subordinate checkboxes to remain selected
        even when the other/none of the above checkbox was selected. 
    4. Extended UIComponent and added public properties so that the class can be instantiated 
        as an MXML tag.
    5. Broke some methods into smaller methods to increase flexibility.
    6. Added the selectedItems property. 
    7. Added the addSubordinate() and removeSubordinate() methods.
    
*/
package com.medratech.bsse.component
{
    import flash.events.Event;
    
    import mx.controls.CheckBox;
    import mx.core.UIComponent;
    
    /**
     * Creates a Master - Subordinate relationship among a specified group of checkboxes. Both the
     * Master checkbox and the array of Subordinate checkboxes must be specified. An Other/None of the above 
     * checkbox is optional.  
     * <p> The Master checkbox serves as a 'select all' box, and should be labeled accordingly. 
     * When the Master is selected, this utility will select all of the Subordinates. When the Master
     * is de-selected, this utility de-selects all of the Subordinates. </p>
     * <p>Selecting or de-selecting the Subordinates has the corresponding effect on the 
     * Master: if one of the Subordinates is de-selected, the utility de-selects the Master.
     * If the selection of a Subordinate results in all of the Subordinates being selected,
     * then this utility selects the Master as well.</p><p>The optional Other checkbox provides 
     * "none of the above" / "other" functionality: If this parameter is supplied, and the Other
     * checkbox is selected, this utility de-selects all other checkboxes in the group.</p>
     * <p>The class extends UIComponent in order that it can be used as an MXML tag. </p>
     */
    public class CheckBoxGroup extends UIComponent 
    {
        
        /**
         * Constructor
         * @param master Checkbox that controls the other checkboxes in the group. 
         * @param subs Array of checkboxes that are subordinate to the master.  
         * @param other Checkbox that indicates "none of the above"
         */
        public function CheckBoxGroup(master:CheckBox=null, subs:Array=null, other:CheckBox=null)
        {
            super();
            // Initialize member variables
            _master = master;
            if(subs) _subs = subs;
            _other = other;
            // Initialize group state and add event listeners
            incorporateCheckBoxes();
            // Keep this control invisible
            visible = false;
            includeInLayout = false;
        }
        
        /**
         * Array of selected checkboxes. The master checkbox is not included in the array,
         * since it is merely indicating that all of the items of value are selected. 
         */
        [Bindable]
        public function get selectedItems():Array
        {
            return _selectedItems;
        }
        /**
         * @private
         */
        public function set selectedItems(value:Array):void
        {
            for each(var checkbox:CheckBox in _subs)
            {
                if(value.indexOf(checkbox) > -1 && !checkbox.selected) 
                {
                    checkbox.selected = true;
                }
                else if(value.indexOf(checkbox) == -1 && checkbox.selected)
                {
                    checkbox.selected = false;
                }
            }
        }
        
        /**
         * Reference to the master checkbox
         */
        public function get master():CheckBox
        {
            return _master;
            if(_master)
            {
                incorporateCheckBoxes();
            }
            else
            {
                removeMasterListener();
            }
        }
        /**
         * @private
         */
        public function set master(value:CheckBox):void
        {
            if(_master && _master == value) return;
            trace("_subs length: " + _subs.length);
            trace("_master: " + _master);
            trace("===============");
            if(_subs.indexOf(value) > -1) throw new Error("The same checkbox cannot be both subordinate and master.");
            if(_other && _other == value) throw new Error("The same checkbox cannot be both other/none of the above and master.");
            _master = value;
            incorporateCheckBoxes();
        }
        /**
         * Array of subordinate checkboxes
         */
        public function get subordinates():Array
        {
            return _subs;
        }
        /**
         * @private
         */
        public function set subordinates(value:Array):void
        {
            _subs = value;
            if(_subs && _subs.length > 0)
            {
                incorporateCheckBoxes();
            }
            else
            {
                removeSubListeners();
            }
        }
        
        /**
         * Other/Select None checkbox
         */
        public function get other():CheckBox
        {
            return _other;
        }
        /**
         * @private
         */
        public function set other(value:CheckBox):void
        {
            if(_other && _other == value) return;
            if(_subs.indexOf(value) > -1) throw new Error("The same checkbox cannot be both other/none of the above and subordinate.");
            if(_master && _master == value) throw new Error("The same checkbox cannot be both master and other/none of the above.");
            _other = value;
            incorporateCheckBoxes();
        }
        
        /**
         * Adds a checkbox to the array of subordinates
         */
        public function addSubordinate(sub:CheckBox):void
        {
            if(_subs.indexOf(sub) > -1) return;
            if(_master == sub) throw new Error("The same checkbox cannot be both master and subordinate.");
            if(_other == sub) throw new Error("The same checkbox cannot be both other/none of the above and subordinate.");
            _subs.push(sub);
            addSubListeners();
            storeStates();
            selectSome(null);
        }
        
        /**
         * Removes a checkbox from the array of subordinates
         */
        public function removeSubordinate(sub:CheckBox):void
        {
            var idx:Number = _subs.indexOf(sub);
            if(idx > -1)
            {
                removeSubListener(sub);
                _subs.splice(idx, 1);
            }
        }
        
        /**
         * Handles chores required when Master and/or Subordinates are set.
         */
        protected function incorporateCheckBoxes():void
        {
            testSubs();
            addEventListeners();
            storeStates();
        }
        
        /**
         * Ensures that the array of subordinates includes only CheckBox instances
         */
        protected function testSubs(): void
        {
            if(!_subs) return;
            for(var i:String in _subs)
            {
                if(!(_subs[i] is CheckBox))
                {
                    throw new Error("The array provided to the CheckBoxGroup constructor must contain only CheckBox instances.");
                }
            }
        }
        
        /**
         * Stores current state (selected / not selected) of the CheckBox instances
         */
        protected function storeStates(): void
        {
            // Makes no sense unless both the master and the subs have been initialized
            if(!_master || !_subs) return;
            _masterSelected = _master.selected;
            _subsSelected = [];
            for(var i:int = 0; i < _subs.length; i++)
            {
                var selected:Boolean = _subs[i].selected;
                _subsSelected[i] = selected;
            }
        }
        
        /**
         * Assigns event listeners to all checkboxes
         */
        protected function addEventListeners(): void
        {
            addMasterListener();
            addSubListeners();
            addOtherListener();
        }
        
        /**
         *  Assigns event listener to master checkbox
         */
        protected function addMasterListener():void
        {
            if(_master)
            {
                removeMasterListener();
                _master.addEventListener(Event.CHANGE, selectAll);
            } 
        }
        
        /**
         * Assigns event listeners to subordinate checkboxes
         */
        protected function addSubListeners():void
        {
            if(_subs)
            removeSubListeners();
            {
                for each(var checkbox:CheckBox in _subs)
                {
                    checkbox.addEventListener(Event.CHANGE, selectSome);
                }
            }
        }
        
        /**
         * Assigns event listener to other/select none checkbox
         */
        protected function addOtherListener():void
        {
            if(_other)
            {
                removeOtherListener();
                _other.addEventListener(Event.CHANGE, selectNone);
            }
        }
        
        /**
         * Removes event listener from master checkbox
         */
        protected function removeMasterListener():void
        {
            _master.removeEventListener(Event.CHANGE, selectAll);
        }
        
        /**
         * Removes event listeners from subordinate checkboxes
         */
        protected function removeSubListeners():void
        {
            if(_subs)
            {
                for each(var checkbox:CheckBox in _subs)
                {
                    removeSubListener(checkbox);
                }
            }
        }
        
        /**
         * Removes event listener from an individual subordinate checkbox
         */
        protected function removeSubListener(sub:CheckBox):void
        {
            sub.removeEventListener(Event.CHANGE, selectSome);
        }
        
        /**
         * Removes event listener from other/select none checkbox
         */
        protected function removeOtherListener():void
        {
            _other.removeEventListener(Event.CHANGE, selectNone);
        }
        
        /**
         * Handles Master checkbox change events. When the master is selected, 
         * it selects all subordinates. When the master is de-selected, it 
         * de-selects all subordinates. 
         */
        protected function selectAll(event:Event): void
        {
            var selected:Boolean = event.target.selected;
            for each(var checkbox:CheckBox in _subs) 
            {
                checkbox.selected = selected;
            } 
            if(selected && _other != null) _other.selected = false;
            selectedItems = _selectedItems;
        }
        
        /**
         * Handles Subordinate checkbox change events. If all subordinates
         * are selected, this function selects the master; otherwise, it
         * de-selects the master.
         */
        protected function selectSome(event:Event): void
        {
            _master.removeEventListener(Event.CHANGE, selectAll);
            _master.selected = allSelected();
            _master.addEventListener(Event.CHANGE, selectAll);
            if((_master.selected || someSelected()) && _other != null) _other.selected = false;
            selectedItems = _selectedItems;
        }
        
        /**
         * Handles Other checkbox change events. When the "other" checkbox is selected,
         * this function de-selects all other checkboxes in the group. When the "other"
         * checkbox is de-selected, all other checkboxes in the group are returned to
         * their most recent state.
         */
        protected function selectNone(event:Event): void 
        {
            var selected:Boolean = event.target.selected;
            if(selected)
            {
                storeStates();
                _master.selected = false;
                for each(var checkbox:CheckBox in _subs)
                {
                    checkbox.selected = false
                }
            }
            else if(!_master.selected)
            {
                _master.selected = _masterSelected;
                for(var i:int = 0; i < _subs.length; i++)
                {
                    _subs[i].selected = _subsSelected[i];
                }
            }
            selectedItems = _selectedItems;
        }
        
        /**
         * Checks to see whether all subordinates are selected. Returns 
         * true if all are selected, false if one or more are not selected.
         */
        protected function allSelected(): Boolean
        {
            var allSelected:Boolean = true;
            for each(var checkbox:CheckBox in _subs)
            {
                if(!checkbox.selected)
                {
                    allSelected = false;
                    break;
                }
            }
            return allSelected;
        }
        
        /**
         * Checks to see whether any subordinate has been selected. 
         * Returns true if at least one subordinate is selected, 
         * otherwise returns false. 
         */
        protected function someSelected():Boolean
        {
            var someSelected:Boolean = false;
            for each(var checkbox:CheckBox in _subs)
            {
                if(checkbox.selected)
                {
                    someSelected = true;
                    break;
                }
            }
            return someSelected;
        }
        
        // Master checkbox
        private var _master:CheckBox;
        // Subordinate checkboxes
        private var _subs:Array = [];
        // Other checkbox
        private var _other:CheckBox;
        // Boolean and arrays to store most recent states
        private var _masterSelected:Boolean;
        private var _subsSelected:Array = [];
        
        private function get _selectedItems():Array
        {
            var arr:Array = [];
            if(_master.selected)
            {
                arr = _subs.concat();
            }
            else
            {
                for each(var checkbox:CheckBox in _subs)
                {
                    if(checkbox.selected)
                        arr.push(checkbox);
                }
            }
            if(_other && _other.selected)
                arr.push(_other);
                
            return arr;
        }
    }
}
