// #wortmann {
// #ТЗ_Счет_НаОплатуКлиенту
// добавление дополнительных реквизитов на форму	
// Галфинд Куканов 2022/07/15	
&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)  
	
	ЭлементГруппаНовыхРеквизитов = Элементы.Добавить("ГруппаРеквизитыДоработок", Тип("ГруппаФормы"), Элементы.ГруппаДополнительно); 
	ЭлементГруппаНовыхРеквизитов.Вид = ВидГруппыФормы.ОбычнаяГруппа;  
	ЭлементГруппаНовыхРеквизитов.Группировка = ГруппировкаПодчиненныхЭлементовФормы.Вертикальная; 
	
	//элементы отображения новых реквизитов документа
	ЭлементСпецификацияПокупателя = Элементы.Добавить("СпецификацияПокупателя", Тип("ПолеФормы"), ЭлементГруппаНовыхРеквизитов); 
	ЭлементСпецификацияПокупателя.Заголовок = "Спецификация покупателя";   
	ЭлементСпецификацияПокупателя.Вид = ВидПоляФормы.ПолеВвода;
	ЭлементСпецификацияПокупателя.ПутьКДанным = "Объект.гф_СпецификацияПокупателя";
	
	ЭлементНомерПоставки = Элементы.Добавить("НомерПоставки", Тип("ПолеФормы"), ЭлементГруппаНовыхРеквизитов);
	ЭлементНомерПоставки.Заголовок = "Номер поставки";   
	ЭлементНомерПоставки.Вид = ВидПоляФормы.ПолеВвода;    
	ЭлементНомерПоставки.ПутьКДанным = "Объект.гф_НомерПоставки";
	
	//элементы для отображения дополнительных реквизитов
	ЭлементГруппаДополнительныеРеквизиты = Элементы.Добавить("ГруппаДополнительныеРеквизиты", Тип("ГруппаФормы"), ЭлементГруппаНовыхРеквизитов); 
	ЭлементГруппаДополнительныеРеквизиты.Вид = ВидГруппыФормы.ОбычнаяГруппа; 
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("Объект", Объект);
	ДополнительныеПараметры.Вставить("ИмяЭлементаДляРазмещения", "ГруппаДополнительныеРеквизиты");
	УправлениеСвойствами.ПриСозданииНаСервере(ЭтотОбъект, ДополнительныеПараметры);
	
КонецПроцедуры// } #wortmann
