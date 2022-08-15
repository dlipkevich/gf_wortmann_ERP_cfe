﻿
#Область ОбработчикиСобытийФормы 

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ТипЦеныЗакупочная = ПланыВидовХарактеристик.гф_ГлобальныеЗначения.НайтиПоРеквизиту(
								"Ключ", "гф_ГлобальныеЗначенияОптоваяЗакупочнаяЦена").Значение;
	
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

&НаКлиенте
Процедура ПутьКФайлуПриИзменении(Элемент)

	//Попытка 
	//	ex = ПолучитьCOMобъект("", "Excel.Application");
	//Исключение
	//	СообщитьПользователю("Excel Application не создан!!");
	//	Возврат;
	//КонецПопытки;
	//
	//Попытка
	//	ex.workbooks.open(ПутьКФайлу, 1);
	//Исключение
	//	СообщитьПользователю("Файл перемещен или удален!");
	//	Возврат;
	//КонецПопытки; 
	
	
	
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗаполнитьЗаказКлиента(Команда)
	
	ВладелецФормы.Объект.гф_ТоварыВКоробах.Очистить();
	
	Для каждого Строка Из ДанныеФайла Цикл
		
		НоваяСтрока = ВладелецФормы.Объект.гф_ТоварыВКоробах.Добавить();
		НоваяСтрока.ВариантКомплектации = Строка.ВариантКомплектации;
		НоваяСтрока.Количество = Строка.Количество;  
		НоваяСтрока.ЦенаКороба = Строка.Цена;
		НоваяСтрока.Сумма = Строка.Сумма; 
		
	КонецЦикла;
	
	ВладелецФормы.Модифицированность = Истина;
	ЭтотОбъект.Закрыть();
	
КонецПроцедуры

&НаСервере
Функция ПолучитьЦенуНоменклатуры(Номенклатура, Характеристика)
	
	Отбор = Новый Структура;
	Отбор.Вставить("Номенклатура", Номенклатура);	
	Отбор.Вставить("ВидЦены", ТипЦеныЗакупочная);
	
	Возврат РегистрыСведений.ЦеныНоменклатуры25.ПолучитьПоследнее(ТекущаяДатаСеанса(), Отбор).Цена;
	
КонецФункции

&НаСервере
Функция НайтиХарактеристикуНоменклатуры(Номенклатура, НаименованиеХарактеристики)
	
	Если Номенклатура.ИспользованиеХарактеристик = 
		Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.ОбщиеДляВидаНоменклатуры  Тогда
		Владелец = Номенклатура.ВидНоменклатуры;
		
	ИначеЕсли  Номенклатура.ИспользованиеХарактеристик = 
		Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.ОбщиеСДругимВидомНоменклатуры Тогда
		
		Владелец = Номенклатура.ВладелецХарактеристик;
	Иначе	
		Владелец = Номенклатура;
	КонецЕсли;	
	
	Возврат Справочники.ХарактеристикиНоменклатуры.НайтиПоНаименованию(НаименованиеХарактеристики, Истина, ,
																		Владелец);	
	
КонецФункции	

&НаСервере
Функция ПолучитьОсновнойВариантКомплектации(Номенклатура, Характеристика)
			
	Запрос = Новый Запрос(
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Таблица.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ВариантыКомплектацииНоменклатуры КАК Таблица
	|ГДЕ
	|	Таблица.Владелец = &Номенклатура
	|	И Таблица.Характеристика = &Характеристика
	|   И Таблица.ПометкаУдаления = Ложь
	|");
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	Запрос.УстановитьПараметр("Характеристика", Характеристика);
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Результат = Выборка.Ссылка;
	Иначе
		Результат = Неопределено;
	КонецЕсли;

	Возврат Результат;;
	
КонецФункции

&НаСервере
Функция НоменклатураПоАртикулу(Артикул)
	
	Возврат Справочники.Номенклатура.НайтиПоРеквизиту("Артикул", Артикул);
	
КонецФункции	

&НаКлиенте
Процедура ПрочитатьФайл(Команда)
	
	ДанныеФайла.Очистить();
	
	НомерКолонкиС  = НомерКолонкиЕксельПоИмени(ВРег(ЗагружатьС));
	НомерКолонкиПо = НомерКолонкиЕксельПоИмени(ВРег(ЗагружатьПо));
	
	Если не ЗначениеЗаполнено(НомерКолонкиС) 
		или не ЗначениеЗаполнено(НомерКолонкиПо) Тогда
		СообщитьПользователю("Не верный формат имен колонок строки ростовки.");
		Возврат;
	КонецЕсли;	
	
	Попытка 
		ex = ПолучитьCOMобъект("", "Excel.Application");
	Исключение
		СообщитьПользователю("Excel Application не создан!!");
		Возврат;
	КонецПопытки;
	
	Попытка
		ex.workbooks.open(ПутьКФайлу, 1);
	Исключение
		СообщитьПользователю("Файл перемещен или удален!");
		Возврат;
	КонецПопытки; 
	
	RCount = ex.ActiveSheet.UsedRange.Rows.Count();
	
	СоответствиеКолонок = Новый Соответствие;
	
	Для Колонка = НомерКолонкиС По НомерКолонкиПо Цикл
		
		_ИмяКолонки = ex.ActiveSheet.Cells(СтрокаНаименованияРостовки, Колонка).Value;
		Размер = Лев(СокрЛП(_ИмяКолонки), 3);
		
		Попытка
			РазмерЧислом = Число(Размер); 
		Исключение
			СообщитьПользователю("Наименование колонки " + _ИмяКолонки + 
						" строки наименования ростовки не соответствует формату. Номер колонки XSL " + Колонка);
			Возврат;
		КонецПопытки;	
		
		СоответствиеКолонок.Вставить(Колонка, Размер);
		
	КонецЦикла;	
		
	Для j = СтрокаЗагрузки По RCount Цикл
			
		Артикул = ex.ActiveSheet.Cells(j, КолонкаАртикул).Value;
		
		Номенклатура = НоменклатураПоАртикулу(СокрЛП(Артикул));
		
		Если Не ЗначениеЗаполнено(Номенклатура) Тогда
			СообщитьПользователю("Не найдена номенклатура с артикулом " + Артикул + " в строке "+ Строка(j));
			Продолжить;
		КонецЕсли;	
		
		Для Колонка = НомерКолонкиС По НомерКолонкиПо Цикл 
			
			_Количество = ex.ActiveSheet.Cells(j, Колонка).Value;
						
			Если ЗначениеЗаполнено(_Количество) Тогда
				
				Попытка
					Количество = Число(СокрЛП(_Количество));
				Исключение
					СообщитьПользователю("Ошибка преобразования в число. Данные по строке XSL " + Строка(j) +
																		"файла XSL не загружены.");
					Продолжить;
				КонецПопытки;
				
				Размер = СоответствиеКолонок.Получить(Колонка);
				
				Характеристика = НайтиХарактеристикуНоменклатуры(Номенклатура, Размер);
				
				Если не ЗначениеЗаполнено(Характеристика) Тогда 
					 СообщитьПользователю("Не найдена характиристика для размера "+ Размер);
					 Продолжить;
				КонецЕсли;	
				
				ВариантКомплектации = ПолучитьОсновнойВариантКомплектации(Номенклатура, Характеристика);
				
				Если ВариантКомплектации = Неопределено Тогда
					СообщитьПользователю("Не найден варинат комплектации для номенклатуры " + 
											Строка(Номенклатура) + " с характеристикой " + 
											Строка(Характеристика) + ". Данные по строке XSL " + 
											Строка(j) + "файла XSL не загружены.");
                    Продолжить;
				КонецЕсли;	
				
				НоваяСтрока = ДанныеФайла.Добавить();
								
				НоваяСтрока.ВариантКомплектации = ВариантКомплектации;
				НоваяСтрока.Количество = Число(Количество);
				НоваяСтрока.Цена = ПолучитьЦенуНоменклатуры(Номенклатура, Характеристика);  
				НоваяСтрока.Сумма = НоваяСтрока.Количество * НоваяСтрока.Цена;
				
			КонецЕсли;	
			
		КонецЦикла;	
		
	КонецЦикла;	
	
	ex.workbooks.Close();
	ex.quit();

КонецПроцедуры  

&НаКлиенте
Функция НомерКолонкиЕксельПоИмени(тИмяКолонки)
  тЛатАлфавит = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  тДлинаНомера = СтрДлина(тИмяКолонки);
 
   тНомерКолонки = 0;
 
   Для тСчет = 1 По тДлинаНомера Цикл
      тПоз = Найти(тЛатАлфавит, Сред(тИмяКолонки, (тДлинаНомера + 1 - тСчет), 1));
      тНомерКолонки = тНомерКолонки + тПоз * Pow(26, тСчет - 1);
   КонецЦикла;
 
   Возврат тНомерКолонки;
КонецФункции

&НаКлиенте
Процедура СообщитьПользователю(Текст)
	
	Сообщение = Новый СообщениеПользователю();
	Сообщение.Текст = Текст;
	Сообщение.Сообщить();
	
КонецПроцедуры	


#КонецОбласти
