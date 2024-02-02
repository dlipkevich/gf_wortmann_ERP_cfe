﻿#Область ЗаполнениеВидовЗапасов

&Вместо("ЗаполнитьВидыЗапасовПоОстаткамКОформлению")
Процедура гф_ЗаполнитьВидыЗапасовПоОстаткамКОформлению(ДокументОбъект, МенеджерВременныхТаблиц, Отказ, ПараметрыЗаполненияВидовЗапасов)
	
	// #wortmann {
	// 1.1 Регистрация возвратов	
	// Галфинд Sakovich 2022/11/29
	Если ПараметрыЗаполненияВидовЗапасов.ПриНехваткеТоваровОрганизацииЗаполнятьВидамиЗапасовПоУмолчанию = Неопределено Тогда
		ТекстИсключения = НСтр("ru = 'В вызывающем коде не задано значение параметра %1.';
		|en = 'Value of the %1 parameter is not specified in the called code.'");
		ТекстИсключения = СтрШаблон(ТекстИсключения, "ПриНехваткеТоваровОрганизацииЗаполнятьВидамиЗапасовПоУмолчанию");
		
		ВызватьИсключение ТекстИсключения;
	КонецЕсли;
	
	Если ПараметрыЗаполненияВидовЗапасов.ПриНехваткеТоваровОрганизацииЗаполнятьВидамиЗапасовПоУмолчанию = Ложь Тогда
		
		ПараметрыЗаполненияВидовЗапасов.ПриНехваткеТоваровОрганизацииЗаполнятьВидамиЗапасовПоУмолчанию = Истина;
		
	КонецЕсли;
	
	ПродолжитьВызов(ДокументОбъект, МенеджерВременныхТаблиц, Отказ, ПараметрыЗаполненияВидовЗапасов);
	// } #wortmann
	
КонецПроцедуры

&ИзменениеИКонтроль("СообщитьОРезультатахКонтроляИзменений")
Процедура гф_СообщитьОРезультатахКонтроляИзменений(РезультатыКонтроля, Документ, Отказ)
	
	#Область ТоварыОрганизаций
	
	Если Не Документ.ДополнительныеСвойства.Свойство("ОтказПриЗаполненииВидовЗапасов")
		И (ПроведениеДокументов.ЕстьЗаписиВТаблице(Документ, "ДвиженияТоварыОрганизацийИзменение")
			Или ПроведениеДокументов.ЕстьЗаписиВТаблице(Документ, "ДвиженияРезервыТоваровОрганизацийИзменение"))
		И РезультатыКонтроля.Свойство("ОшибкиТоварыОрганизацийРезервыСводно")
		И ЗначениеЗаполнено(РезультатыКонтроля.ОшибкиТоварыОрганизацийРезервыСводно) Тогда
		
		СтрокиОшибок = РезультатыКонтроля.ОшибкиТоварыОрганизацийРезервыСводно;
		
		КонтролироватьОтрицательныеОстатки = Не ПараметрыСеанса.ПроводитьБезКонтроляОстатковТоваровОрганизаций
			И Константы.КонтролироватьОстаткиТоваровОрганизаций.Получить();
			#Вставка
			// #wortmann {
			// vvv Галфинд \ Sakovich 26.11.2023
			// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee593709e3289f
			гф_НеКонтролироватьОтрицательныеОстатки = гф_НеКонтролироватьОтрицательныеОстатки(Документ);
			Если гф_НеКонтролироватьОтрицательныеОстатки Тогда
				КонтролироватьОтрицательныеОстатки = Ложь;
			КонецЕсли;
			// ^^^ Галфинд \ Sakovich 26.11.2023
			// } #wortmann
			#КонецВставки
		ПерезаполнитьВидыЗапасов = Документ.ДополнительныеСвойства.Свойство("ПерезаполнитьВидыЗапасов")
			И Документ.ДополнительныеСвойства.ПерезаполнитьВидыЗапасов;
		
		ПриНехваткеТоваровОрганизацииЗаполнятьВидамиЗапасовПоУмолчанию =
			Документ.ДополнительныеСвойства.Свойство("ПараметрыЗаполненияВидовЗапасов")
			И ПриНехваткеТоваровОрганизацииЗаполнятьВидамиЗапасовПоУмолчанию(
				Документ.ДополнительныеСвойства.ПараметрыЗаполненияВидовЗапасов);
		
		ОтрицательныйОстаток = 0;
		ПокрывающийРезерв = 0;
		
		Индекс = 0;
		КоличествоСтрок = СтрокиОшибок.Количество();
		
		Пока Индекс < КоличествоСтрок Цикл
			
			СтрокаОшибки = СтрокиОшибок[Индекс];
			Индекс = Индекс + 1;
			
			Если Не ПерезаполнитьВидыЗапасов Тогда
				ОтрицательныйОстаток = Мин(СтрокаОшибки.КоличествоОстаток, ОтрицательныйОстаток);
				ПокрывающийРезерв = Макс(СтрокаОшибки.РезервОстаток, ПокрывающийРезерв);
			КонецЕсли;
			
			// Проверка на отрицательный остаток.
			Если КонтролироватьОтрицательныеОстатки
				И СтрокаОшибки.КоличествоОстаток + СтрокаОшибки.РезервОстаток < 0
				И Не ПриНехваткеТоваровОрганизацииЗаполнятьВидамиЗапасовПоУмолчанию Тогда
				
				ТекстСообщения = НСтр("ru = 'По организации %Организация% на %Месяц% обнаружен отрицательный остаток %Количество% %ЕдиницаИзмерения% товара %Товар% в месте хранения %МестоХранения%';
										|en = 'By company %Организация% for the %Месяц% negative balance detected %Количество% %ЕдиницаИзмерения% of goods %Товар% in storage location %МестоХранения%'");
				
				Если СтрокаОшибки.Период = ДатаАктуальныхОстатков() Тогда
					ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Месяц%", НСтр("ru = 'дату актуальности остатков';
																				|en = 'balance relevance date'"));
				КонецЕсли;
				
				ЗаполнитьОбщиеПараметрыТекстеСообщенияОбОшибкахПроведенияПоТоварамОрганизацийИРезервам(
					ТекстСообщения, Документ.Ссылка, СтрокаОшибки);
				ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Количество%", СтрокаОшибки.КоличествоОстаток + СтрокаОшибки.РезервОстаток);
				ТекстСообщения = СтрЗаменить(ТекстСообщения, "%ЕдиницаИзмерения%", СтрокаОшибки.ЕдиницаИзмерения);
				#Удаление
				ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Товар%", СтрокаОшибки.Номенклатура);
				#КонецУдаления
				#Вставка
				// Галфинд \ Sakovich 02.02.2024
				лХарактеристика = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаОшибки.АналитикаУчетаНоменклатуры, "Характеристика");
				лНомерГТД = "ГТД: " + СтрокаОшибки.НомерГТД;
				лПредставлениеНоменклатуры = НоменклатураКлиентСервер.ПредставлениеНоменклатуры(
					СтрокаОшибки.Номенклатура, 
					лХарактеристика, ,
					лНомерГТД);
				ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Товар%", лПредставлениеНоменклатуры);
				#КонецВставки
				ТекстСообщения = СтрЗаменить(ТекстСообщения, "%МестоХранения%", СтрокаОшибки.МестоХранения);
				
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, Документ,,, Отказ);
				
			КонецЕсли;
			
			Если КонтролироватьОтрицательныеОстатки 
				И СтрокаОшибки.КОформлениюСписанияОстаток < 0 Тогда
				
				ТекстСообщения = НСтр("ru = 'По организации %Организация% на %Месяц% обнаружен отрицательный остаток к оформлению списания %Количество% %ЕдиницаИзмерения% товара %Товар% в месте хранения %МестоХранения%';
										|en = 'By company %Организация% for the %Месяц% negative balance detected for write-off %Количество% %ЕдиницаИзмерения% of goods %Товар% in storage location %МестоХранения%'");
				
				Если СтрокаОшибки.Период = ДатаАктуальныхОстатков() Тогда
					ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Месяц%", НСтр("ru = 'дату актуальности остатков';
																				|en = 'balance relevance date'"));
				КонецЕсли;
				
				ЗаполнитьОбщиеПараметрыТекстеСообщенияОбОшибкахПроведенияПоТоварамОрганизацийИРезервам(
					ТекстСообщения, Документ.Ссылка, СтрокаОшибки);
				ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Количество%", СтрокаОшибки.КОформлениюСписанияОстаток);
				ТекстСообщения = СтрЗаменить(ТекстСообщения, "%ЕдиницаИзмерения%", СтрокаОшибки.ЕдиницаИзмерения);
				#Удаление
				ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Товар%", СтрокаОшибки.Номенклатура);
				#КонецУдаления
				#Вставка
				// Галфинд \ Sakovich 02.02.2024
				лХарактеристика = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаОшибки.АналитикаУчетаНоменклатуры, "Характеристика");
				лНомерГТД = "ГТД: " + СтрокаОшибки.НомерГТД;
				лПредставлениеНоменклатуры = НоменклатураКлиентСервер.ПредставлениеНоменклатуры(
					СтрокаОшибки.Номенклатура, 
					лХарактеристика, ,
					лНомерГТД);
				ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Товар%", лПредставлениеНоменклатуры);
				#КонецВставки
				ТекстСообщения = СтрЗаменить(ТекстСообщения, "%МестоХранения%", СтрокаОшибки.МестоХранения);
				
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, Документ,,, Отказ);
				
			КонецЕсли;
			
			Если Индекс = КоличествоСтрок
				Или СтрокаОшибки.Организация <> СтрокиОшибок[Индекс].Организация
				Или СтрокаОшибки.АналитикаУчетаНоменклатуры <> СтрокиОшибок[Индекс].АналитикаУчетаНоменклатуры
				Или СтрокаОшибки.ВидЗапасов <> СтрокиОшибок[Индекс].ВидЗапасов
				Или СтрокаОшибки.НомерГТД <> СтрокиОшибок[Индекс].НомерГТД Тогда
			
				// Общая проверка лишнего резерва по всем периодам.
				Если ОтрицательныйОстаток + ПокрывающийРезерв > 0 Тогда
					ТекстСообщения = НСтр("ru = 'При записи %Регистратор% в регистры %Регистр1% и %Регистр2%
					|обнаружен лишний резерв по измерениям: %Организация% - %АналитикаНоменклатуры% - %ВидЗапасов% - %НомерГТД%, лишний резерв %Дельта%.';
					|en = 'While writing %Регистратор% to the %Регистр1% and %Регистр2% registers,
					|an excessive reserve was found for dimensions: %Организация% - %АналитикаНоменклатуры% - %ВидЗапасов% - %НомерГТД%, extra reserve %Дельта%.'");
					ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Регистр2%", "РезервыТоваровОрганизаций");
					ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Регистр1%", "ТоварыОрганизаций");
					
					ЗаполнитьОбщиеПараметрыТекстеСообщенияОбОшибкахПроведенияПоТоварамОрганизацийИРезервам(ТекстСообщения, Документ.Ссылка, СтрокаОшибки);
					ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Дельта%", ОтрицательныйОстаток + ПокрывающийРезерв);
					
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, Документ,,, Отказ);
				КонецЕсли;
				
				ОтрицательныйОстаток = 0;
				ПокрывающийРезерв = 0;
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЕсли;
	
	#КонецОбласти
	
	#Область ТоварыКОформлениюДокументовИмпорта
	
	Если ПроведениеДокументов.ЕстьЗаписиВТаблице(Документ, "ДвиженияТоварыКОформлениюДокументовИмпортаИзменение") Тогда
		
		ШаблонСообщенияБезПоступления = НСтр("ru = 'Номенклатура %1
			|Превышен остаток товара к оформлению на складе %2 на %3 %4';
			|en = 'Items %1
			|Balance of goods for clearance in stock is exceeded %2 by %3 %4'");
		ШаблонСообщенияСПоступлением = ШаблонСообщенияБезПоступления + " " + НСтр("ru = 'по документу %5';
																					|en = 'by document %5'");
		
		Для каждого СтрокаОшибки Из РезультатыКонтроля.ОшибкиТоварыКОформлениюДокументовИмпорта Цикл
			
			ПредставлениеНоменклатуры = НоменклатураКлиентСервер.ПредставлениеНоменклатуры(
				СтрокаОшибки.Номенклатура, СтрокаОшибки.Характеристика, , СтрокаОшибки.Серия);
			
            #Вставка
			// #wortmann {
			// ++ Галфинд_Домнышева_КР_17_03_2023
			ПредставлениеНоменклатуры = ПредставлениеНоменклатуры + " с артикулом " + СтрокаОшибки.Номенклатура.Артикул;
			// -- Галфинд_Домнышева_КР_17_03_2023
			// } #wortmann
			#КонецВставки
			Если ЗначениеЗаполнено(СтрокаОшибки.ДокументПоступления) Тогда
				ТекстСообщения = СтрШаблон(ШаблонСообщенияСПоступлением, ПредставлениеНоменклатуры,
				СтрокаОшибки.Склад, -СтрокаОшибки.Количество, СтрокаОшибки.ЕдиницаИзмерения, СтрокаОшибки.ДокументПоступления);
			Иначе
				ТекстСообщения = СтрШаблон(ШаблонСообщенияБезПоступления, ПредставлениеНоменклатуры,
				СтрокаОшибки.Склад, -СтрокаОшибки.Количество, СтрокаОшибки.ЕдиницаИзмерения);
			КонецЕсли;

			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, Документ,,, Отказ);

		КонецЦикла;

	КонецЕсли;

	#КонецОбласти

КонецПроцедуры

#КонецОбласти

#Область Проведение

&Перед("ПослеЗаписиДвиженийДокумента")
Процедура гф_ПослеЗаписиДвиженийДокумента(Документ, МенеджерВременныхТаблиц, Отказ)
	// #wortmann {
	// vvv Галфинд \ Sakovich 26.11.2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee593709e3289f
	гф_НеКонтролироватьОтрицательныеОстатки = гф_НеКонтролироватьОтрицательныеОстатки(Документ);
	Если гф_НеКонтролироватьОтрицательныеОстатки Тогда
		Если Документ.ДополнительныеСвойства.Свойство("ЗаписыватьРезервыТоваровОрганизацийВместеСоВсеми") Тогда
			Документ.ДополнительныеСвойства["ЗаписыватьРезервыТоваровОрганизацийВместеСоВсеми"] = Истина;
		Иначе	
			Документ.ДополнительныеСвойства.Вставить("ЗаписыватьРезервыТоваровОрганизацийВместеСоВсеми", Истина);
		КонецЕсли;
	КонецЕсли;
	// ^^^ Галфинд \ Sakovich 26.11.2023
	// } #wortmann
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// #wortmann {
// vvv Галфинд \ Sakovich 26.11.2023
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee593709e3289f
Функция гф_НеКонтролироватьОтрицательныеОстатки(Документ)
	НеКонтролироватьОтрицательныеОстатки = Ложь;
	Если ТипЗнч(Документ) = Тип("ДокументОбъект.РеализацияТоваровУслуг") 
		Или ТипЗнч(Документ) = Тип("ДокументОбъект.ВозвратТоваровОтКлиента") Тогда
		Если Документ["Склад"]["гф_АгентскийСклад"] Тогда
			НеКонтролироватьОтрицательныеОстатки = Истина;
		КонецЕсли;
	КонецЕсли;
	Возврат НеКонтролироватьОтрицательныеОстатки;
КонецФункции// } #wortmann

#КонецОбласти


