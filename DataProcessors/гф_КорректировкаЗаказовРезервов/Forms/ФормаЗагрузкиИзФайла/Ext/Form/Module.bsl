﻿
#Область ОбработчикиСобытийФормы 

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	флТоварыВКоробах = Параметры.флТоварыВКоробах;
	Если флТоварыВКоробах Тогда
		Элементы.ДанныеФайлаНоменклатура.Видимость = Ложь;
	Иначе
		Элементы.ДанныеФайлаВариантКомплектации.Видимость = Ложь;
	КонецЕсли;
КонецПроцедуры 

&НаКлиенте
Процедура ПутьКФайлуНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Заголовок = "Выберите файл загрузки";
	Диалог.Фильтр = "Файлы Excel (*.xls, *.xlsx)|*.xl*";
	Диалог.ПолноеИмяФайла = ""; 	 
    Диалог.МножественныйВыбор = Ложь;
	
	Если Диалог.Выбрать() Тогда
		ПутьКФайлу = Диалог.ПолноеИмяФайла;
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗаполнитьЗаказКлиента(Команда)
	
	Результат = ПолучитьМассивСтруктур();
	Закрыть(Результат);
	
КонецПроцедуры

&НаСервере
Функция ПолучитьМассивСтруктур()
	МассивСтруктур = Новый Массив;
	Для Каждого СтрокаТЗ Из ДанныеФайла Цикл
		нс = Новый Структура("Номенклатура, Характеристика, ВариантКомплектации, Добавить, Удалить");
		ЗаполнитьЗначенияСвойств(нс, СтрокаТЗ);
		МассивСтруктур.Добавить(нс);
	КонецЦикла;
	Возврат МассивСтруктур;
КонецФункции

&НаСервере
Функция НайтиХарактеристикуНоменклатуры(Номенклатура, ХарактеристикаНаименование, флДобавитьСтрокуФайла, j)
	
	Если Не ЗначениеЗаполнено(СокрЛП(ХарактеристикаНаименование)) Тогда
		//флДобавитьСтрокуФайла = Ложь;
		Возврат Справочники.ХарактеристикиНоменклатуры.ПустаяСсылка();
	КонецЕсли;
	Если Номенклатура.ИспользованиеХарактеристик = 
		Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.ОбщиеДляВидаНоменклатуры  Тогда
		Владелец = Номенклатура.ВидНоменклатуры;
		
	ИначеЕсли  Номенклатура.ИспользованиеХарактеристик = 
		Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.ОбщиеСДругимВидомНоменклатуры Тогда
		Владелец = Номенклатура.ВладелецХарактеристик;
		
	Иначе
		Владелец = Номенклатура;
		
	КонецЕсли;
	
	Характеристика = Справочники.ХарактеристикиНоменклатуры.НайтиПоНаименованию(ХарактеристикаНаименование, Истина, ,
		Владелец);
	Если Не ЗначениеЗаполнено(Характеристика) Тогда 
		ТекстСообщения = "Не найдена характеристика для размера " + ХарактеристикаНаименование;
		СообщитьПользователю(ТекстСообщения);
		флДобавитьСтрокуФайла = Ложь;
	КонецЕсли;	
	Возврат Характеристика;
	
КонецФункции	

&НаСервере
Функция ПолучитьОсновнойВариантКомплектации(Номенклатура, Характеристика, флДобавитьСтрокуФайла, j)
			
	Если	Не ЗначениеЗаполнено(Номенклатура)
		ИЛИ	Не ЗначениеЗаполнено(Характеристика) Тогда
		флДобавитьСтрокуФайла = Ложь;
		Возврат Справочники.ВариантыКомплектацииНоменклатуры.ПустаяСсылка();
	КонецЕсли;
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
	|	Таблица.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ВариантыКомплектацииНоменклатуры КАК Таблица
	|ГДЕ
	|	Таблица.Владелец = &Номенклатура
	|	И Таблица.Характеристика = &Характеристика
	|	И Таблица.ПометкаУдаления = ЛОЖЬ");
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	Запрос.УстановитьПараметр("Характеристика", Характеристика);
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		ВариантКомплектации = Выборка.Ссылка;
	Иначе
		ВариантКомплектации = Справочники.ВариантыКомплектацииНоменклатуры.ПустаяСсылка();
	КонецЕсли;

	Если Не ЗначениеЗаполнено(ВариантКомплектации) Тогда
		ТекстСообщения = "Не найден вариант комплектации для номенклатуры "
							+ Строка(Номенклатура) + " с характеристикой "
							+ Строка(Характеристика) + ". Данные по строке XSL "
							+ Строка(j) + "файла XSL не загружены.";
		СообщитьПользователю(ТекстСообщения);
		флДобавитьСтрокуФайла = Ложь;
	КонецЕсли;
	Возврат ВариантКомплектации;
	
КонецФункции

&НаСервере
Функция НоменклатураПоАртикулу(Артикул, флДобавитьСтрокуФайла, j)
	
	Если НЕ ЗначениеЗаполнено(Артикул) Тогда
		флДобавитьСтрокуФайла = Ложь;
		Возврат Справочники.Номенклатура.ПустаяСсылка();
	КонецЕсли;
	Номенклатура = Справочники.Номенклатура.НайтиПоРеквизиту("Артикул", Артикул);
	Если Не ЗначениеЗаполнено(Номенклатура) Тогда
		ТекстСообщения = "Не найдена номенклатура с артикулом " + Артикул + " в строке " + Строка(j);
		СообщитьПользователю(ТекстСообщения);
		флДобавитьСтрокуФайла = Ложь;
	КонецЕсли;
	Возврат Номенклатура;
	
КонецФункции	

&НаКлиенте
Процедура ПрочитатьФайл(Команда)
	
	ДанныеФайла.Очистить();
	
	Попытка 
		ex = ПолучитьCOMобъект("", "Excel.Application");
	Исключение
		СообщитьПользователю("Excel Application не создан!");
		Возврат;
	КонецПопытки;
	
	Попытка
		ex.workbooks.open(ПутьКФайлу, 1);
	Исключение
		СообщитьПользователю("Файл перемещен или удален!");
		Возврат;
	КонецПопытки; 
	
	RCount = ex.ActiveSheet.UsedRange.Rows.Count();
	
	СтрокаЗагрузки  = 2;
	Для j = СтрокаЗагрузки По RCount Цикл
		
		флДобавитьСтрокуФайла = Истина;
			
		Артикул = ex.ActiveSheet.Cells(j, 1).Text;
		Номенклатура = НоменклатураПоАртикулу(СокрЛП(Артикул), флДобавитьСтрокуФайла, j);
		
		ХарактеристикаНаименование = СокрЛП(ex.ActiveSheet.Cells(j, 2).Text);
		Характеристика = НайтиХарактеристикуНоменклатуры(Номенклатура, ХарактеристикаНаименование,
			флДобавитьСтрокуФайла, j);
				
		Если флТоварыВКоробах Тогда
			ВариантКомплектации = ПолучитьОсновнойВариантКомплектации(Номенклатура, Характеристика, флДобавитьСтрокуФайла, j);
		КонецЕсли;
		
		Добавить = 0;
		_Добавить = СокрЛП(ex.ActiveSheet.Cells(j, 3).Value);
		Если ЗначениеЗаполнено(_Добавить) Тогда
			ОписаниеТипа = Новый ОписаниеТипов("Число");
			Добавить = ОписаниеТипа.ПривестиЗначение(_Добавить);
		КонецЕсли;

		Удалить = 0;
		_Удалить = СокрЛП(ex.ActiveSheet.Cells(j, 4).Value);
		Если ЗначениеЗаполнено(_Удалить) Тогда
			ОписаниеТипа = Новый ОписаниеТипов("Число");
			Удалить = ОписаниеТипа.ПривестиЗначение(_Удалить);
		КонецЕсли;

		Если Не флДобавитьСтрокуФайла Тогда
			Продолжить;
		КонецЕсли;
		НоваяСтрока = ДанныеФайла.Добавить();
		НоваяСтрока.Артикул = Артикул;
		НоваяСтрока.ХарактеристикаНаименование = ХарактеристикаНаименование;
		НоваяСтрока.Добавить = Добавить;
		НоваяСтрока.Удалить = Удалить;
		НоваяСтрока.Номенклатура = Номенклатура;
		НоваяСтрока.Характеристика = Характеристика;
		НоваяСтрока.ВариантКомплектации = ВариантКомплектации;
		
	КонецЦикла;	
	
	ex.workbooks.Close();
	ex.quit();
	
КонецПроцедуры  

&НаСервереБезКонтекста
Процедура СообщитьПользователю(Текст)
	
	Сообщение = Новый СообщениеПользователю();
	Сообщение.Текст = Текст;
	Сообщение.Сообщить();
	
КонецПроцедуры	

#КонецОбласти
